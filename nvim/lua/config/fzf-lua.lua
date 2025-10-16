local ok, fzf = pcall(require, "fzf-lua")
if not ok then return end

fzf.setup({
  defaults = { file_icons = "mini" },
  winopts  = {
    row = 0.5,
    height = 0.7,
    -- NOTE: do not set "hl" here; it's deprecated upstream
  },
  files    = { previewer = false },
})

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local uv = vim.uv or vim.loop

local function has(exe) return vim.fn.executable(exe) == 1 end

local function norm_dir(p)
  if not p or p == "" then return nil end
  local abs = vim.fn.fnamemodify(p, ":p")
  local st  = uv.fs_stat(abs)
  if st and st.type == "directory" then
    return vim.fs.normalize(abs)
  end
  return nil
end

-- Longest common ancestor directory of a list of absolute paths
local function common_ancestor(paths)
  if #paths == 0 then return vim.loop.cwd() end
  local sep = package.config:sub(1,1)
  local parts = vim.split(paths[1], sep, { plain = true })
  for i = 2, #paths do
    local p2 = vim.split(paths[i], sep, { plain = true })
    local j = 1
    while j <= #parts and j <= #p2 and parts[j] == p2[j] do j = j + 1 end
    while #parts >= j do table.remove(parts) end
  end
  local root = table.concat(parts, sep)
  if root == "" then root = sep end
  return root
end

-- Build fd options that restrict to multiple directories
local function fd_search_paths(dirs)
  -- fd: --search-path {dir} can be repeated
  local opts = { "--hidden", "--follow" }
  for _, d in ipairs(dirs) do
    table.insert(opts, "--search-path"); table.insert(opts, d)
  end
  return table.concat(opts, " ")
end

-- Build ripgrep globs to limit search to given subdirs (from a common base)
local function rg_globs(base, dirs)
  -- convert each dir into a relative glob 'dir/**'
  local sep = package.config:sub(1,1)
  local add = {}
  for _, d in ipairs(dirs) do
    local rel = d:gsub("^"..vim.pesc(base)..sep.."?", "")
    if rel == "" then
      add = {}
      break
    end
    table.insert(add, "--glob")
    table.insert(add, rel .. "/**")
  end
  local opts = { "--hidden", "--follow" }
  for _, g in ipairs(add) do table.insert(opts, g) end
  return table.concat(opts, " ")
end

---------------------------------------------------------------------------
-- Visual selection helpers
---------------------------------------------------------------------------
-- queued query: set by visual mappings, consumed by :GrepHere / :FilesHere
local _queued_query = nil

local function get_visual_text_inclusive(vmode)
  local bufnr = 0
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
  if srow == 0 or erow == 0 then return "" end

  -- normalize order
  if (erow < srow) or (erow == srow and ecol < scol) then
    srow, erow, scol, ecol = erow, srow, ecol, scol
  end

  local start_col = (vmode == "V") and 0      or scol
  local end_col   = (vmode == "V") and -1     or (ecol + 1)

  local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, start_col, erow - 1, end_col, {})
  local s = table.concat(lines, " ")
  return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

---------------------------------------------------------------------------
-- User commands
--  :GrepHere [dir]        – live_grep inside one directory (default: CWD)
--  :FilesHere [dir]       – list files inside one directory (default: CWD)
--  :FilesDirs {d1} {d2}…  – list files across multiple directories
---------------------------------------------------------------------------
vim.api.nvim_create_user_command("GrepHere", function(opts)
  local dir = opts.args ~= "" and norm_dir(opts.args) or vim.loop.cwd()
  if not dir then
    vim.notify("Not a directory: "..opts.args, vim.log.levels.ERROR)
    return
  end
  local cfg = { cwd = dir, resume = false }
  if _queued_query and _queued_query ~= "" then
    cfg.search = _queued_query
  end
  _queued_query = nil
  fzf.live_grep(cfg)
end, { nargs = "?", complete = "dir", desc = "live_grep in one directory" })

vim.api.nvim_create_user_command("FilesHere", function(opts)
  local dir = opts.args ~= "" and norm_dir(opts.args) or vim.loop.cwd()
  if not dir then
    vim.notify("Not a directory: "..opts.args, vim.log.levels.ERROR)
    return
  end
  local cfg = { cwd = dir, resume = false }
  if _queued_query and _queued_query ~= "" then
    cfg.fzf_opts = { ["--query"] = _queued_query }
  end
  _queued_query = nil
  fzf.files(cfg)
end, { nargs = "?", complete = "dir", desc = "files in one directory" })

vim.api.nvim_create_user_command("FilesDirs", function(opts)
  local raw = opts.fargs or {}
  if #raw == 0 then
    vim.notify("Usage: :FilesDirs {dir1} {dir2} …", vim.log.levels.WARN)
    return
  end
  local dirs = {}
  for _, a in ipairs(raw) do
    local d = norm_dir(a)
    if d then table.insert(dirs, d) else vim.notify("Skip (not a dir): "..a, vim.log.levels.WARN) end
  end
  if #dirs == 0 then return end

  local anc = common_ancestor(dirs)
  local cfg = { cwd = anc, resume = false }

  if has("fd") or has("fdfind") then
    cfg.fd_opts = fd_search_paths(dirs)      -- use fd across multiple roots
  else
    cfg.rg_opts = rg_globs(anc, dirs)        -- fallback: rg --files with globs
  end

  -- If a queued query exists (e.g., you called :FilesDirs after a visual map),
  -- use it to pre-fill the filename filter.
  if _queued_query and _queued_query ~= "" then
    cfg.fzf_opts = { ["--query"] = _queued_query }
  end
  _queued_query = nil

  fzf.files(cfg)
end, { nargs = "+", complete = "dir", desc = "files in multiple directories" })

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------
-- Regular pickers
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>",     { desc = "Fuzzy find files",     silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Fuzzy grep (ripgrep)", silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<CR>",  { desc = "Help tags",             silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<CR>",     { desc = "Buffer tags",           silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>",   { desc = "Open buffers",          silent = true })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>",  { desc = "Recent files",          silent = true })

-- Choose a directory (normal) → one-dir grep/files
vim.keymap.set("n", "<leader>sd", function()
  local keys = vim.api.nvim_replace_termcodes(":GrepHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "live_grep in chosen dir", silent = true })

vim.keymap.set("n", "<leader>fd", function()
  local keys = vim.api.nvim_replace_termcodes(":FilesHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "files in chosen dir", silent = true })

-- NEW: multi-folder file search (normal)
vim.keymap.set("n", "<leader>fD", function()
  local keys = vim.api.nvim_replace_termcodes(":FilesDirs ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "files in multiple dirs", silent = true })

-- Visual mode:
-- <leader>sd → choose dir; seed selection into grep query
vim.keymap.set("x", "<leader>sd", function()
  local vmode = vim.fn.visualmode()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    local q = get_visual_text_inclusive(vmode)
    _queued_query = (q ~= "" and q or nil)
    local keys = vim.api.nvim_replace_termcodes(":GrepHere ", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end)
end, { desc = "live_grep (seeded by selection) in chosen dir", silent = true })

-- <leader>fd → choose dir; seed selection into files picker filter
vim.keymap.set("x", "<leader>fd", function()
  local vmode = vim.fn.visualmode()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    local q = get_visual_text_inclusive(vmode)
    _queued_query = (q ~= "" and q or nil)
    local keys = vim.api.nvim_replace_termcodes(":FilesHere ", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end)
end, { desc = "files (seeded by selection) in chosen dir", silent = true })

-- Visual selection → plain live_grep with selection (no dir prompt)
vim.keymap.set("x", "<leader>fg", function()
  local vmode = vim.fn.visualmode()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    local q = get_visual_text_inclusive(vmode)
    if q ~= "" then fzf.live_grep({ search = q, resume = false })
    else             fzf.live_grep({ resume = false }) end
  end)
end, { desc = "Fuzzy grep selection", silent = true })

-- Paste from system clipboard (+) in terminal/fzf prompts
vim.keymap.set('t', '<C-r>+', function()
  return vim.fn.getreg('+')
end, { expr = true, desc = 'Paste + into terminal/fzf' })

