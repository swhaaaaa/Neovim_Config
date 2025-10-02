-- =============================================================================
-- Cscope async tools + cscope_maps setup
-- REQUIRE: sudo apt install cscope
-- Optional speedups: fd (aka fdfind) and/or ripgrep
-- =============================================================================

-- Default Keymaps
-- <prefix>: <leader>c
-- <prefix>: <C-c>

-- Keymaps 	Description
-- <prefix>s 	find all references to the token under cursor
-- <prefix>g 	find global definition(s) of the token under cursor
-- <prefix>c 	find all calls to the function name under cursor
-- <prefix>t 	find all instances of the text under cursor
-- <prefix>e 	egrep search for the word under cursor
-- <prefix>f 	open the filename under cursor
-- <prefix>i 	find files that include the filename under cursor
-- <prefix>d 	find functions that function under cursor calls
-- <prefix>a 	find places where this symbol is assigned a value
-- <prefix>b 	build cscope database
-- Ctrl-] 	do :Cstag <cword>

-- convert cs to Cs in command line mode
vim.fn["utils#Cabbrev"]("cs", "Cs")

-- --- cscope_maps: sane defaults + project auto-detection ---------------------
local has_telescope = pcall(require, "telescope")
local ok_csm, csm = pcall(require, "cscope_maps")
if ok_csm then
  csm.setup({
    disable_maps = false,           -- keep plugin's <leader>c{sgcteifd} maps
    skip_input_prompt = false,
    prefix = "<leader>c",
    cscope = {
      db_file = "./cscope.out",     -- per-project database file
      exec = "cscope",              -- or "gtags-cscope"
      picker = has_telescope and "telescope" or "quickfix",
      picker_opts = { window_pos = "bottom", window_size = 8 },
      skip_picker_for_single_result = true,
      db_build_cmd = { script = "default", args = { "-bqkv" } },
      project_rooter = { enable = true, change_cwd = false },
      tag = { keymap = true, order = { "cs", "tag_picker", "tag" }, tag_cmd = "tjump" },
    },
  })
end

-- lua/config/cscope.lua
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

local function project_root()
  local marks = {
    ".git", "compile_commands.json", "Makefile", "package.json",
    "pyproject.toml", "Cargo.toml", "go.mod"
  }
  return vim.fs.root(0, marks) or vim.loop.cwd()
end

local function has(exe) return vim.fn.executable(exe) == 1 end

-- Fast-event safe notify
local function notify(msg, level)
  local lvl = level or vim.log.levels.INFO
  local function do_notify() vim.notify(msg, lvl, { title = "Cscope" }) end
  if vim.in_fast_event() then vim.schedule(do_notify) else do_notify() end
end

-- Paths
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

-- Convert any user string to a valid directory (expands ~; if file -> dirname)
local function normalize_dir(p)
  if not p or p == "" then return nil end
  p = vim.fn.fnamemodify(p, ":p")
  local st = uv.fs_stat(p)
  if st and st.type ~= "directory" then
    p = vim.fs.dirname(p)
    st = uv.fs_stat(p)
  end
  if not st or st.type ~= "directory" then
    return nil, ("Not a directory: %s"):format(p)
  end
  return p
end

local function resolve_root(arg)
  if arg and arg ~= "" then
    local dir, err = normalize_dir(arg)
    if not dir then return nil, err end
    return dir
  end
  -- return project_root()
  return vim.loop.cwd()  -- was project_root()
end

-- If user passes a directory → append "cscope.files"; if file → use it
local function resolve_list(arg, fallback_root)
  if not arg or arg == "" then
    -- local root = fallback_root or project_root()
    local root = fallback_root or vim.loop.cwd()  -- was project_root()
    -- return (root .. "/cscope.files"), root
    return (vim.fs.normalize(root .. "/cscope.files")), root
  end
  local p = vim.fn.fnamemodify(arg, ":p")
  local st = uv.fs_stat(p)
  if st and st.type == "directory" then
    return (vim.fs.normalize(p .. "/cscope.files")), p
  else
    local dir = vim.fs.dirname(p)
    return p, dir
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
      on_stderr = function(_, data)
        if data then table.insert(err, table.concat(data, "\n")) end
      end,
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

  notify("Cscope: scanning files…")

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

    if cmd ~= "fd" and cmd ~= "fdfind" then
      to_abs_paths(files, root) -- rg/find → make absolute
    end

    -- Write list (absolute paths)
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

-- ---------- Build (async; accepts file list path) ----------
function M.build_async(opts, cb)
  opts = opts or {}
  if not has("cscope") then
    notify("Missing `cscope` executable (sudo apt install cscope).", vim.log.levels.ERROR)
    if cb then cb("cscope missing") end
    return
  end

  -- Resolve list path and its directory
  local fallback_root = project_root()
  local list, list_dir = resolve_list(opts.list, fallback_root)
  local out = opts.out or (list_dir .. "/cscope.out")

  -- Ensure list exists & non-empty; if not, generate into that exact path
  local st = uv.fs_stat(list)
  local function do_build()
    notify("Cscope: building database…")
    run_cmd_async("cscope", { "-bqk", "-i", list, "-f", out }, list_dir, function(code, _, err)
      if code ~= 0 then
        notify("cscope build failed: " .. (err or ""), vim.log.levels.ERROR)
        if cb then cb(err or "build failed") end
        return
      end
      notify("Built " .. out)
      if cb then cb(nil, out) end
    end)
  end

  if not st or st.size == 0 then
    notify("cscope.files missing or empty; generating…")
    M.generate_async({ root = list_dir, out = list }, function(gen_err, _, count)
      if gen_err or not count or count == 0 then
        if cb then cb(gen_err or "no files") end
        return
      end
      do_build()
    end)
  else
    do_build()
  end
end


-- ---------- User commands (now default to ./ and ./cscope.files) ----------
-- :CscopeFiles [folder] → generate <folder>/cscope.files (absolute paths)
vim.api.nvim_create_user_command("CscopeFiles", function(opts)
  local root, rerr
  if opts.args ~= "" then
    root, rerr = resolve_root(opts.args)
    if not root then return notify(rerr, vim.log.levels.ERROR) end
  else
    root = vim.loop.cwd()  -- default: ./ 
  end
  M.generate_async({ root = root, out = root .. "/cscope.files" })
end, { nargs = "?", complete = "dir", desc = "Generate ./cscope.files (absolute, async) or at [folder]" })

-- :CscopeBuild [filelist] → build DB from a specific cscope.files path
-- If omitted, uses ./cscope.files in current dir
vim.api.nvim_create_user_command("CscopeBuild", function(opts)
  local list
  if opts.args ~= "" then
    list = vim.fn.fnamemodify(opts.args, ":p")
  else
    list = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")  -- default: ./cscope.files
  end
  M.build_async({ list = list })
end, { nargs = "?", complete = "file", desc = "Build cscope.out (async) from ./cscope.files or [filelist]" })

-- -- ---------- User commands ----------
-- -- :CscopeFiles [folder]  → generate <folder>/cscope.files (absolute paths)
-- vim.api.nvim_create_user_command("CscopeFiles", function(opts)
--   local root, rerr = resolve_root(opts.args)
--   if not root then return notify(rerr, vim.log.levels.ERROR) end
--   M.generate_async({ root = root })
-- end, { nargs = "?", complete = "dir", desc = "Generate cscope.files (absolute, async) at [folder]" })

-- -- :CscopeBuild [filelist] → build DB from a specific cscope.files path
-- -- If [filelist] is a directory, uses [filelist]/cscope.files
-- vim.api.nvim_create_user_command("CscopeBuild", function(opts)
--   local list, _ = resolve_list(opts.args, project_root())
--   M.build_async({ list = list })
-- end, { nargs = "?", complete = "file", desc = "Build cscope.out (async) from [filelist]" })

-- -- Prompt, then "global def" of <cword>
-- vim.keymap.set({ "n", "v" }, "<C-c><C-g>", "<cmd>CsPrompt g<cr>", { desc = "Cscope: global def (prompt)" })
-- -- Direct, no prompt
-- vim.keymap.set({ "n", "v" }, "<C-c><C-s>", "<cmd>Cs f s<cr>",      { desc = "Cscope: references" })

return M
