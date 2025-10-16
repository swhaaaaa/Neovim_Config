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
-- Options
---------------------------------------------------------------------------
-- If true, grep uses --fixed-strings so the seeded text is literal.
local LITERAL_BY_DEFAULT = false

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

local function fd_search_paths(dirs)
  local opts = { "--hidden", "--follow" }
  for _, d in ipairs(dirs) do
    table.insert(opts, "--search-path"); table.insert(opts, d)
  end
  return table.concat(opts, " ")
end

local function rg_globs(base, dirs)
  local sep = package.config:sub(1,1)
  local add = {}
  for _, d in ipairs(dirs) do
    local rel = d:gsub("^"..vim.pesc(base)..sep.."?", "")
    if rel == "" then add = {}; break end
    table.insert(add, "--glob"); table.insert(add, rel .. "/**")
  end
  local opts = { "--hidden", "--follow" }
  for _, g in ipairs(add) do table.insert(opts, g) end
  return table.concat(opts, " ")
end

---------------------------------------------------------------------------
-- Visual selection (robust)
-- Works in Visual mode WITHOUT leaving it; if not in Visual, reselects with gv.
---------------------------------------------------------------------------
local function get_visual_selection()
  local mode = vim.fn.mode()
  local save_z  = vim.fn.getreg('z')
  local save_zt = vim.fn.getregtype('z')

  if mode == 'v' or mode == 'V' or mode == '\022' then
    -- still in Visual → yank exact selection
    vim.cmd([[noautocmd normal! "zy]])
  else
    -- not in Visual (e.g. mapping called after an <Esc>) → reselect last region
    vim.cmd([[noautocmd normal! gv"zy]])
  end

  local txt = vim.fn.getreg('z') or ""

  -- restore register z
  vim.fn.setreg('z', save_z, save_zt)

  -- single-line & trimmed for rg/fzf
  txt = txt:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  return txt
end

-- queued query used by :GrepHere / :FilesHere / :FilesDirs
local _queued_query = nil

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------
vim.api.nvim_create_user_command("GrepHere", function(opts)
  local dir = opts.args ~= "" and norm_dir(opts.args) or vim.loop.cwd()
  if not dir then
    vim.notify("Not a directory: "..opts.args, vim.log.levels.ERROR)
    return
  end
  local cfg = { cwd = dir, resume = false, silent = true }
  if _queued_query and _queued_query ~= "" then
    cfg.search = _queued_query
    if LITERAL_BY_DEFAULT then
      cfg.rg_opts = (cfg.rg_opts and (cfg.rg_opts .. " ") or "") .. "--fixed-strings"
    end
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
    cfg.fd_opts = fd_search_paths(dirs)
  else
    cfg.rg_opts = rg_globs(anc, dirs)
  end

  if _queued_query and _queued_query ~= "" then
    cfg.fzf_opts = { ["--query"] = _queued_query }
  end
  _queued_query = nil

  fzf.files(cfg)
end, { nargs = "+", complete = "dir", desc = "files in multiple directories" })

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>",     { desc = "Fuzzy find files",     silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Fuzzy grep (ripgrep)", silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<CR>",  { desc = "Help tags",             silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<CR>",     { desc = "Buffer tags",           silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>",   { desc = "Open buffers",          silent = true })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>",  { desc = "Recent files",          silent = true })

-- Normal → choose a directory
vim.keymap.set("n", "<leader>sd", function()
  local keys = vim.api.nvim_replace_termcodes(":GrepHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "live_grep in chosen dir", silent = true })

vim.keymap.set("n", "<leader>fd", function()
  local keys = vim.api.nvim_replace_termcodes(":FilesHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "files in chosen dir", silent = true })

-- Multi-folder (normal)
vim.keymap.set("n", "<leader>fD", function()
  local keys = vim.api.nvim_replace_termcodes(":FilesDirs ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "files in multiple dirs", silent = true })

-- Visual → seed selection WITHOUT leaving Visual first
vim.keymap.set("x", "<leader>sd", function()
  _queued_query = get_visual_selection()
  local keys = vim.api.nvim_replace_termcodes(":GrepHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "live_grep (seeded by selection) in chosen dir", silent = true })

vim.keymap.set("x", "<leader>fd", function()
  _queued_query = get_visual_selection()
  local keys = vim.api.nvim_replace_termcodes(":FilesHere ", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "files (seeded by selection) in chosen dir", silent = true })

-- Visual → plain live_grep (no dir prompt)
vim.keymap.set("x", "<leader>fg", function()
  local q = get_visual_selection()
  local cfg = { resume = false, silent = true }
  if q ~= "" then
    cfg.search = q
    if LITERAL_BY_DEFAULT then
      cfg.rg_opts = "--fixed-strings"
    end
  end
  fzf.live_grep(cfg)
end, { desc = "Fuzzy grep selection", silent = true })

-- Paste from system clipboard (+) in terminal/fzf prompts
vim.keymap.set('t', '<C-r>+', function()
  return vim.fn.getreg('+')
end, { expr = true, desc = 'Paste + into terminal/fzf' })

