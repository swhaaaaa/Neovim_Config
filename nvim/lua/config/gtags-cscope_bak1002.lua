-- convert cs to Cs in command line mode
vim.fn["utils#Cabbrev"]("cs", "Cs")

-- --- cscope_maps: gtags backend + Telescope picker --------------------------
local has_telescope = pcall(require, "telescope")
local ok_csm, csm = pcall(require, "cscope_maps")
if ok_csm then
  csm.setup({
    disable_maps = false,
    skip_input_prompt = false,
    prefix = "<leader>c",

    cscope = {
      db_file = "./GTAGS",              -- fine for gtags
      exec = "gtags-cscope",            -- use GNU Global's shim
      picker = has_telescope and "telescope" or "quickfix",
      picker_opts = { window_pos = "bottom", window_size = 8 },
      skip_picker_for_single_result = true,

      -- let plugin run gtags; label is handled in our builder too
      db_build_cmd = { script = "gtags", args = { "--gtagslabel=ctags" } },

      project_rooter = { enable = true, change_cwd = false },
      tag = { keymap = true, order = { "cs", "tag_picker", "tag" }, tag_cmd = "tjump" },
    },
  })
end

-- lua/config/cscope.lua (GTAGS-first builder; defaults to ./ and ./cscope.files)
local M = {}

-- ---------- Config ----------
M.extensions = {
  "c","h","cpp","hpp","cc","hh","cxx","hxx",
  "java","kt","kts","scala",
  "js","jsx","ts","tsx",
  "go","rs",
  "py","rb","sh","bash","zsh",
  "lua","vim","vimrc",
  "m","mm","swift","zig",
}

M.ignores = {
  ".git","node_modules",".venv","venv","__pycache__","target","build","dist","out",
  ".next",".cache","coverage","bin","obj",".idea",".vscode","vendor",".tox",".pytest_cache",
}

-- ---------- Utils ----------
local uv = vim.uv or vim.loop
local function has(exe) return vim.fn.executable(exe) == 1 end

local function notify(msg, level)
  local lvl = level or vim.log.levels.INFO
  local function do_notify() vim.notify(msg, lvl, { title = "Cscope/GTAGS" }) end
  if vim.in_fast_event() then vim.schedule(do_notify) else do_notify() end
end

-- paths/helpers
local function is_abs(p)
  if vim.fn.has("win32") == 1 then
    return p:match("^%a:[/\\]") or p:match("^\\\\")
  end
  return p:sub(1,1) == "/"
end
local function abs_join(root, p)
  if is_abs(p) then return vim.fs.normalize(p) end
  p = p:gsub("^%./+", "")
  return vim.fs.normalize(root .. "/" .. p)
end
local function to_abs_paths(files, root)
  for i = 1, #files do files[i] = abs_join(root, files[i]) end
  return files
end

-- arg → valid dir; if file path, use its parent
local function normalize_dir(p)
  if not p or p == "" then return nil end
  p = vim.fn.fnamemodify(p, ":p")
  local st = uv.fs_stat(p)
  if st and st.type ~= "directory" then
    p = vim.fs.dirname(p); st = uv.fs_stat(p)
  end
  if not st or st.type ~= "directory" then
    return nil, ("Not a directory: %s"):format(p)
  end
  return p
end

-- DEFAULT to CWD (./) if no arg
local function resolve_root(arg)
  if arg and arg ~= "" then
    local dir, err = normalize_dir(arg)
    if not dir then return nil, err end
    return dir
  end
  return vim.loop.cwd()
end

-- DEFAULT to ./cscope.files if no arg
-- If a directory is passed → append /cscope.files; if a file → use it
local function resolve_list(arg, fallback_root)
  if not arg or arg == "" then
    local root = fallback_root or vim.loop.cwd()
    return (vim.fs.normalize(root .. "/cscope.files")), root
  end
  local p = vim.fn.fnamemodify(arg, ":p")
  local st = uv.fs_stat(p)
  if st and st.type == "directory" then
    return (vim.fs.normalize(p .. "/cscope.files")), p
  else
    return p, vim.fs.dirname(p)
  end
end

-- ---------- Async runner ----------
local function run_cmd_async(cmd, args, cwd, on_done)
  args = args or {}
  local function finish(code, lines, err)
    if not on_done then return end
    if vim.in_fast_event() then
      vim.schedule(function() on_done(code, lines, err) end)
    else
      on_done(code, lines, err)
    end
  end
  if not cwd then return finish(1, {}, "cwd not resolved") end
  local st = uv.fs_stat(cwd)
  if not st or st.type ~= "directory" then
    return finish(1, {}, "cwd is not a directory: " .. tostring(cwd))
  end

  if vim.system then
    vim.system(vim.list_extend({ cmd }, args), { cwd = cwd, text = true }, function(obj)
      local lines = vim.split(obj.stdout or "", "\n", { trimempty = true })
      finish(obj.code, lines, obj.stderr)
    end)
  else
    local out, err = {}, {}
    local ok = vim.fn.jobstart(vim.list_extend({ cmd }, args), {
      cwd = cwd, stdout_buffered = true, stderr_buffered = true,
      on_stdout = function(_, data)
        if not data then return end
        for _, line in ipairs(data) do if line and line ~= "" then table.insert(out, line) end end
      end,
      on_stderr = function(_, data) if data then table.insert(err, table.concat(data, "\n")) end end,
      on_exit = function(_, code) finish(code, out, table.concat(err, "\n")) end,
    })
    if ok <= 0 then finish(1, {}, "jobstart failed") end
  end
end

-- ---------- Generate (async; absolute paths) ----------
function M.generate_async(opts, cb)
  opts = opts or {}
  local root, rerr = resolve_root(opts.root)
  if not root then
    notify(rerr or "Failed to resolve root", vim.log.levels.ERROR)
    if cb then cb(rerr or "resolve root failed") end
    return
  end
  local outfile = opts.out or (root .. "/cscope.files")
  local exts    = opts.extensions or M.extensions
  local ignores = opts.ignores or M.ignores

  notify("Scanning files for tags…")

  local cmd, args
  if has("fd") or has("fdfind") then
    cmd = has("fd") and "fd" or "fdfind"
    args = { "--type", "f", "--hidden", "--follow", "--absolute-path", "." }
    for _, e in ipairs(exts) do table.insert(args, "-e"); table.insert(args, e) end
    for _, ig in ipairs(ignores) do table.insert(args, "-E"); table.insert(args, ig) end
  elseif has("rg") then
    cmd = "rg"
    args = { "--files", "--hidden", "--follow" }
    for _, ig in ipairs(ignores) do table.insert(args, "-g"); table.insert(args, "!" .. ig) end
    for _, e in ipairs(exts) do table.insert(args, "-g"); table.insert(args, "*." .. e) end
  else
    cmd = "find"
    local name_expr = {}
    for i, e in ipairs(exts) do
      if i > 1 then table.insert(name_expr, "-o") end
      table.insert(name_expr, "-name"); table.insert(name_expr, "*." .. e)
    end
    args = { ".", "-type", "f", "\\(", unpack(name_expr), "\\)", "-print" }
    for _, ig in ipairs(ignores) do
      table.insert(args, "-not"); table.insert(args, "-path"); table.insert(args, "*/" .. ig .. "/*")
    end
  end

  run_cmd_async(cmd, args, root, function(code, files, err)
    if code ~= 0 then
      notify("File scan failed: " .. (err or ""), vim.log.levels.ERROR)
      if cb then cb(err or "scan failed") end
      return
    end
    if cmd ~= "fd" and cmd ~= "fdfind" then to_abs_paths(files, root) end

    local ok, fh = pcall(io.open, outfile, "w")
    if not ok or not fh then
      notify("Cannot write " .. outfile, vim.log.levels.ERROR)
      if cb then cb("cannot write file") end
      return
    end
    for _, f in ipairs(files) do fh:write(f, "\n") end
    fh:close()

    notify(("Wrote %d paths → %s"):format(#files, outfile))
    if cb then cb(nil, outfile, #files) end
  end)
end

-- ---------- Build (async; GTAGS preferred, fallback to cscope) ----------
local function build_gtags_with_label(list, list_dir, label, cb)
  notify(("GTAGS: building (%s)…"):format(label))
  run_cmd_async("gtags", { "--gtagslabel=" .. label, "-f", list }, list_dir, function(code, _, err)
    if code == 0 then
      notify("Built " .. (list_dir .. "/GTAGS"))
      if cb then cb(nil, list_dir .. "/GTAGS") end
    else
      if cb then cb(err or ("gtags failed (" .. label .. ")")) end
    end
  end)
end

function M.build_async(opts, cb)
  opts = opts or {}
  -- resolve file list (default ./cscope.files)
  local list, list_dir = resolve_list(opts.list, vim.loop.cwd())
  local use_gtags = has("gtags")
  local out = use_gtags and (list_dir .. "/GTAGS") or (list_dir .. "/cscope.out")

  local function do_build_with_cscope()
    if not has("cscope") then
      notify("Neither `gtags` nor `cscope` found. Install GNU Global.", vim.log.levels.ERROR)
      if cb then cb("no indexer") end
      return
    end
    notify("Cscope: building database…")
    run_cmd_async("cscope", { "-bqk", "-i", list, "-f", out }, list_dir, function(code, _, err)
      if code ~= 0 then
        notify("cscope build failed: " .. (err or ""), vim.log.levels.ERROR)
        if cb then cb(err or "cscope build failed") end
        return
      end
      notify("Built " .. out)
      if cb then cb(nil, out) end
    end)
  end

  local st = uv.fs_stat(list)
  local function start_build()
    if use_gtags then
      -- Try modern Universal-ctags labels first, then native
      build_gtags_with_label(list, list_dir, "new-ctags", function(err1)
        if not err1 then return end
        build_gtags_with_label(list, list_dir, "ctags", function(err2)
          if not err2 then return end
          build_gtags_with_label(list, list_dir, "native", function(err3)
            if err3 then
              notify("gtags build failed after all labels; falling back to cscope.", vim.log.levels.WARN)
              do_build_with_cscope()
            end
          end)
        end)
      end)
    else
      do_build_with_cscope()
    end
  end

  if not st or st.size == 0 then
    notify("File list missing or empty; generating…")
    M.generate_async({ root = list_dir, out = list }, function(gen_err, _, count)
      if gen_err or not count or count == 0 then
        if cb then cb(gen_err or "no files") end
        return
      end
      start_build()
    end)
  else
    start_build()
  end
end

-- ---------- User commands (defaults: ./ and ./cscope.files) ----------
-- :CscopeFiles [folder] → write ./cscope.files (or under [folder])
vim.api.nvim_create_user_command("CscopeFiles", function(opts)
  local root
  if opts.args ~= "" then
    local r, err = resolve_root(opts.args)
    if not r then return notify(err, vim.log.levels.ERROR) end
    root = r
  else
    root = vim.loop.cwd()
  end
  M.generate_async({ root = root, out = root .. "/cscope.files" })
end, { nargs = "?", complete = "dir", desc = "Generate ./cscope.files (absolute, async) or at [folder]" })

-- :CscopeBuild [filelist] → build GTAGS (or cscope.out) from ./cscope.files by default
vim.api.nvim_create_user_command("CscopeBuild", function(opts)
  local list
  if opts.args ~= "" then
    list = vim.fn.fnamemodify(opts.args, ":p")
  else
    list = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  end
  M.build_async({ list = list })
end, { nargs = "?", complete = "file", desc = "Build GTAGS (preferred) from ./cscope.files or [filelist]" })

return M
