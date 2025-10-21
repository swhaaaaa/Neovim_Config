local fn = vim.fn
local api = vim.api

local utils = require("utils")

-- Display a message when the current file is not in utf-8 format.
-- Note that we need to use `unsilent` command here because of this issue:
-- https://github.com/vim/vim/issues/4379
api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*",
  group = api.nvim_create_augroup("non_utf8_file", { clear = true }),
  callback = function()
    if vim.bo.fileencoding ~= "utf-8" then
      vim.notify("File not in UTF-8 format!", vim.log.levels.WARN, { title = "nvim-config" })
    end
  end,
})

-- highlight yanked region, see `:h lua-highlight`
local yank_group = api.nvim_create_augroup("highlight_yank", { clear = true })
api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = "*",
  group = yank_group,
  callback = function()
    vim.hl.on_yank { higroup = "YankColor", timeout = 300 }
  end,
})

api.nvim_create_autocmd({ "CursorMoved" }, {
  pattern = "*",
  group = yank_group,
  callback = function()
    vim.g.current_cursor_pos = vim.fn.getcurpos()
  end,
})

api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = yank_group,
  ---@diagnostic disable-next-line: unused-local
  callback = function(context)
    if vim.v.event.operator == "y" then
      vim.fn.setpos(".", vim.g.current_cursor_pos)
    end
  end,
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  group = api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(ctx)
    local dir = fn.fnamemodify(ctx.file, ":p:h")
    utils.may_create_dir(dir)
  end,
})

-- Automatically reload the file if it is changed outside of Nvim, see https://unix.stackexchange.com/a/383044/221410.
-- It seems that `checktime` does not work in command line. We need to check if we are in command
-- line before executing this command, see also https://vi.stackexchange.com/a/20397/15292 .
api.nvim_create_augroup("auto_read", { clear = true })

api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  pattern = "*",
  group = "auto_read",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN, { title = "nvim-config" })
  end,
})

api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
  pattern = "*",
  group = "auto_read",
  callback = function()
    if fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize all windows when we resize the terminal
api.nvim_create_autocmd("VimResized", {
  group = api.nvim_create_augroup("win_autoresize", { clear = true }),
  desc = "autoresize windows on resizing operation",
  command = "wincmd =",
})

local function open_nvim_tree(data)
  -- check if buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not directory then
    return
  end

  -- create a new, empty buffer
  vim.cmd.enew()

  -- wipe the directory buffer
  vim.cmd.bw(data.buf)

  -- open the tree
  require("nvim-tree.api").tree.open()
end

api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- Do not use smart case in command line mode, extracted from https://vi.stackexchange.com/a/16511/15292.
api.nvim_create_augroup("dynamic_smartcase", { clear = true })
api.nvim_create_autocmd("CmdLineEnter", {
  group = "dynamic_smartcase",
  pattern = ":",
  callback = function()
    vim.o.smartcase = false
  end,
})

api.nvim_create_autocmd("CmdLineLeave", {
  group = "dynamic_smartcase",
  pattern = ":",
  callback = function()
    vim.o.smartcase = true
  end,
})

api.nvim_create_autocmd("TermOpen", {
  group = api.nvim_create_augroup("term_start", { clear = true }),
  pattern = "*",
  callback = function()
    -- Do not use number and relative number for terminal inside nvim
    vim.wo.relativenumber = false
    vim.wo.number = false

    -- Go to insert mode by default to start typing command
    vim.cmd("startinsert")
  end,
})

local number_toggle_group = api.nvim_create_augroup("numbertoggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  pattern = "*",
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("custom_highlight", { clear = true }),
  pattern = "*",
  desc = "Define or overrride some highlight groups",
  callback = function()
    -- For yank highlight
    vim.api.nvim_set_hl(0, "YankColor", { fg = "#34495E", bg = "#2ECC71", ctermfg = 59, ctermbg = 41 })

    -- For cursor colors
    vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "#00c918", bold = true })
    vim.api.nvim_set_hl(0, "Cursor2", { fg = "red", bg = "red" })

    -- For floating windows border highlight
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "LightGreen", bg = "None", bold = true })

    local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
    -- change the background color of floating window to None, so it blenders better
    vim.api.nvim_set_hl(0, "NormalFloat", { fg = hl.fg, bg = "None" })

    -- highlight for matching parentheses
    vim.api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true })
  end,
})

api.nvim_create_autocmd("BufEnter", {
  group = api.nvim_create_augroup("auto_close_win", { clear = true }),
  desc = "Quit only if the last *real* window is a special FT and no other listed buffers exist",
  callback = function()
    -- mark “special” filetypes that can be sole window
    local quit_fts = { qf = true, help = true, NvimTree = true, vista = true }

    -- collect non-floating windows in current tab
    local real_wins = {}
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      local cfg = api.nvim_win_get_config(win)
      if cfg.relative == "" then  -- ignore floating wins
        table.insert(real_wins, win)
      end
    end

    -- need exactly one real window
    if #real_wins ~= 1 then return end

    local win = real_wins[1]
    local buf = api.nvim_win_get_buf(win)
    local ft  = vim.api.nvim_get_option_value("filetype", { buf = buf })

    -- last window must be a special filetype
    if not quit_fts[ft] then return end

    -- if there are other listed buffers (e.g. your 'init.lua'), don't quit
    local listed = vim.fn.getbufinfo({ buflisted = 1 })
    -- keep only listed buffers that are not the current special buffer
    local others = 0
    for _, info in ipairs(listed) do
      if info.bufnr ~= buf then others = others + 1 end
    end
    if others > 0 then return end

    -- Now it's safe to close the editor/tab
    vim.cmd("quit")
  end,
})

api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  group = api.nvim_create_augroup("git_repo_check", { clear = true }),
  pattern = "*",
  desc = "check if we are inside Git repo",
  callback = function()
    utils.inside_git_repo()
  end,
})

-- Mark for reading the large bin file to Hexdump
-- ref: https://vi.stackexchange.com/a/169/15292
api.nvim_create_autocmd("BufReadPre", {
  group = api.nvim_create_augroup("large_file", { clear = true }),
  pattern = "*",
  desc = "optimize for large file",
  callback = function(ev)
    -- local file_size_limit = 524288 -- 0.5MB
    local file_size_limit = 10485760 -- 10MB
    local f = ev.file

    if fn.getfsize(f) > file_size_limit or fn.getfsize(f) == -2 then
      vim.o.eventignore = "all"

      -- show ruler
      vim.o.ruler = true

      --  turning off relative number helps a lot
      vim.wo.relativenumber = false
      vim.wo.number = false

      vim.bo.swapfile = false
      vim.bo.bufhidden = "unload"
      vim.bo.undolevels = -1
    end
  end,
})

