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

-- ============================== lua/config/cscope.lua ==============================
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
  local function do_notify() vim.notify(msg, lvl, { title = "Cscope" }) end
  if vim.in_fast_event() then vim.schedule(do_notify) else do_notify() end
end

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

-- DEFAULT to CWD list path
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
      on_stderr = function(_, data)
        if data then table.insert(err, table.concat(data, "\n")) end
      end,
      on_exit = function(_, code) finish(code, out, table.concat(err, "\n")) end,
    })
    if ok <= 0 then finish(1, {}, "jobstart failed") end
  end
end

-- ---------- Scanners ----------
local function scan_async(root, opts, cb)
  opts = opts or {}
  local exts    = opts.extensions or M.extensions
  local ignores = opts.ignores or M.ignores

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
    if code ~= 0 then return cb(err or "scan failed") end
    if cmd ~= "fd" and cmd ~= "fdfind" then to_abs_paths(files, root) end
    cb(nil, files or {})
  end)
end

local function scan_many_async(roots, opts, cb)
  if not roots or #roots == 0 then return cb(nil, {}) end
  local pending = #roots
  local agg, seen = {}, {}
  local err_accum

  for _, r in ipairs(roots) do
    scan_async(r, opts, function(err, files)
      if err then
        err_accum = (err_accum or "") .. (err_accum and "\n" or "") .. err
        notify("Scan warning: " .. err, vim.log.levels.WARN)
      else
        for _, p in ipairs(files) do
          p = vim.fs.normalize(p)
          if not seen[p] then seen[p] = true; table.insert(agg, p) end
        end
      end
      pending = pending - 1
      if pending == 0 then cb(err_accum, agg) end
    end)
  end
end

-- ---------- List I/O ----------
local function read_list(list_path)
  local paths, set = {}, {}
  local fh = io.open(list_path, "r")
  if not fh then return paths, set end
  for line in fh:lines() do
    local p = line:gsub("%s+$", "")
    if p ~= "" then
      p = vim.fs.normalize(vim.fn.fnamemodify(p, ":p"))
      if not set[p] then set[p] = true; table.insert(paths, p) end
    end
  end
  fh:close()
  return paths, set
end

local function write_list(list_path, paths)
  local ok, fh = pcall(io.open, list_path, "w")
  if not ok or not fh then return false end
  for _, p in ipairs(paths) do fh:write(p, "\n") end
  fh:close()
  return true
end

-- ---------- Generate / Build ----------
function M.generate_async(opts, cb)
  opts = opts or {}
  local root = opts.root or vim.loop.cwd()
  local outfile = opts.out or (vim.loop.cwd() .. "/cscope.files")
  local exts = opts.extensions or M.extensions
  local ignores = opts.ignores or M.ignores

  notify("Cscope: scanning files…")
  scan_async(root, { extensions = exts, ignores = ignores }, function(err, files)
    if err then
      notify("File scan failed: " .. err, vim.log.levels.ERROR)
      if cb then cb(err) end
      return
    end
    if not write_list(outfile, files or {}) then
      notify("Cannot write " .. outfile, vim.log.levels.ERROR)
      if cb then cb("write failed") end
      return
    end
    notify(("Wrote %d paths → %s"):format(#files, outfile))
    if cb then cb(nil, outfile, #files) end
  end)
end

function M.build_async(opts, cb)
  opts = opts or {}
  if not has("cscope") then
    notify("Missing `cscope` executable (sudo apt install cscope).", vim.log.levels.ERROR)
    if cb then cb("cscope missing") end
    return
  end

  local list, list_dir = resolve_list(opts.list, vim.loop.cwd())
  local out = opts.out or (list_dir .. "/cscope.out")
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

-- ---------- Multi-root helpers ----------
function M.generate_from_roots_async(roots, out, opts, cb)
  opts = opts or {}
  notify("Cscope: scanning multiple folders…")
  scan_many_async(roots, opts, function(err, files)
    if err and (not files or #files == 0) then
      notify("Scan failed: " .. err, vim.log.levels.ERROR)
      if cb then cb(err) end
      return
    end
    if not write_list(out, files or {}) then
      notify("Cannot write " .. out, vim.log.levels.ERROR)
      if cb then cb("write failed") end
      return
    end
    notify(("Wrote %d paths → %s"):format(#files, out))
    if cb then cb(nil, out, #files) end
  end)
end

function M.add_dirs_to_list_async(args, cb)
  args = args or {}
  local list = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  local roots = args.roots or { vim.loop.cwd() }

  scan_many_async(roots, args, function(err, files)
    if err then notify("Scan warning: " .. err, vim.log.levels.WARN) end
    local existing, set = read_list(list)
    local added = 0
    for _, p in ipairs(files or {}) do
      p = vim.fs.normalize(p)
      if not set[p] then set[p] = true; table.insert(existing, p); added = added + 1 end
    end
    if not write_list(list, existing) then
      notify("Cannot write " .. list, vim.log.levels.ERROR)
      if cb then cb("write failed") end
      return
    end
    notify(("Appended %d (now %d) → %s"):format(added, #existing, list))
    if cb then cb(nil, list, added, #existing) end
  end)
end

-- ---------- Import / Unique ----------
function M.merge_lists_async(args, cb)
  args = args or {}
  local target = args.target or vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  target = vim.fn.fnamemodify(target, ":p")

  local sources = args.sources or {}
  if #sources == 0 then
    notify("No source lists provided", vim.log.levels.ERROR)
    if cb then cb("no sources") end
    return
  end

  for i, s in ipairs(sources) do
    local p = vim.fn.fnamemodify(s, ":p")
    local st = uv.fs_stat(p)
    if st and st.type == "directory" then p = vim.fs.normalize(p .. "/cscope.files") end
    sources[i] = p
  end

  local out_list, set = read_list(target)
  local before = #out_list
  for _, src in ipairs(sources) do
    local l = read_list(src)
    for _, p in ipairs(l) do
      if not set[p] then set[p] = true; table.insert(out_list, p) end
    end
  end

  if not write_list(target, out_list) then
    notify("Cannot write " .. target, vim.log.levels.ERROR)
    if cb then cb("write failed") end
    return
  end
  local added = #out_list - before
  notify(("Merged %d new paths → %s"):format(added, target))
  if cb then cb(nil, target, added, #out_list) end
end

function M.unique_list(list_path)
  list_path = list_path and vim.fn.fnamemodify(list_path, ":p")
              or vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  local paths, _ = read_list(list_path)
  if not write_list(list_path, paths) then
    notify("Cannot write " .. list_path, vim.log.levels.ERROR)
    return
  end
  notify(("Deduplicated → %s (%d lines)"):format(list_path, #paths))
end

-- =========================== User commands =========================== --

-- :CscopeFiles [dir1] [dir2] ...  -> overwrite CWD ./cscope.files
-- :CscopeFiles! [dir1] [dir2] ... -> append (de-dup) into CWD ./cscope.files
local function parse_roots_from_fargs(fargs)
  local set, roots = {}, {}
  if not fargs or #fargs == 0 then return { vim.loop.cwd() } end
  for _, a in ipairs(fargs) do
    local r, err = normalize_dir(a)
    if r then
      r = vim.fs.normalize(r)
      if not set[r] then set[r] = true; table.insert(roots, r) end
    else
      notify("Skip: " .. a .. " (" .. (err or "invalid") .. ")", vim.log.levels.WARN)
    end
  end
  if #roots == 0 then roots = { vim.loop.cwd() } end
  return roots
end

vim.api.nvim_create_user_command("CscopeFiles", function(opts)
  local roots = parse_roots_from_fargs(opts.fargs)
  local list  = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  if opts.bang then
    M.add_dirs_to_list_async({ roots = roots, list = list })
  else
    M.generate_from_roots_async(roots, list, {}, nil)
  end
end, {
  nargs = "*",
  bang = true,
  complete = "dir",
  desc = "Write CWD ./cscope.files from [dir1..]; use ! to append (de-dup)",
})

-- :CscopeFilesAdd [dir1] [dir2] ... -> append multiple folders (de-dup)
vim.api.nvim_create_user_command("CscopeFilesAdd", function(opts)
  local roots = parse_roots_from_fargs(opts.fargs)
  local list  = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  M.add_dirs_to_list_async({ roots = roots, list = list })
end, { nargs = "*", complete = "dir", desc = "Append [dir1..] into CWD ./cscope.files (de-dup)" })

-- :CscopeImport {filelist} [...]  -> merge lists into CWD ./cscope.files (de-dup)
vim.api.nvim_create_user_command("CscopeImport", function(opts)
  local args = opts.fargs or {}
  if #args == 0 then return notify("Usage: :CscopeImport {filelist} [...]", vim.log.levels.WARN) end
  M.merge_lists_async({
    target = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files"),
    sources = args
  })
end, { nargs = "+", complete = "file", desc = "Merge file lists into CWD ./cscope.files (de-dup)" })

-- :CscopeUnique [filelist] -> deduplicate a list (default CWD ./cscope.files)
vim.api.nvim_create_user_command("CscopeUnique", function(opts)
  local path = opts.args ~= "" and opts.args or nil
  M.unique_list(path)
end, { nargs = "?", complete = "file", desc = "De-duplicate a cscope.files (default CWD ./cscope.files)" })

-- :CscopeBuild [filelist] → build cscope.out (defaults to CWD ./cscope.files)
vim.api.nvim_create_user_command("CscopeBuild", function(opts)
  local list
  if opts.args ~= "" then
    list = vim.fn.fnamemodify(opts.args, ":p")
  else
    list = vim.fs.normalize((vim.loop.cwd() or ".") .. "/cscope.files")
  end
  M.build_async({ list = list })
end, { nargs = "?", complete = "file", desc = "Build cscope.out from CWD ./cscope.files or given list" })

return M
