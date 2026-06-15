local keymap = vim.keymap
local uv = vim.uv or vim.loop

-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ";", ":")

-- Turn the word under cursor to upper case
keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
keymap.set("i", "<c-t>", "<Esc>b~lea")

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Shortcut for faster save and quit
keymap.set("n", "<leader>w", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- Saves the file if modified and quit
keymap.set("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "quit current window" })

-- Quit all opened buffers
keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
keymap.set("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", {
  silent = true,
  desc = "close qf and location list",
})

-- Delete current buffer without closing the window (force works on binary/unlisted too)
keymap.set("n", [[\d]], function()
  local cur_buf = vim.api.nvim_win_get_buf(0)
  local ok = pcall(vim.cmd, "bprevious")
  if not ok then
    vim.cmd("enew")
  end
  pcall(vim.api.nvim_buf_delete, cur_buf, { force = true })
end, {
  silent = true,
  desc = "delete current buffer (force)",
})

keymap.set("n", [[\D]], function()
  local buf_ids = vim.api.nvim_list_bufs()
  local cur_buf = vim.api.nvim_win_get_buf(0)

  for _, buf_id in pairs(buf_ids) do
    if buf_id ~= cur_buf then
      -- force delete both listed and unlisted (binary, special) buffers
      pcall(vim.api.nvim_buf_delete, buf_id, { force = true })
    end
  end

  -- also force-delete current buffer if it is not listed (e.g. binary file)
  local cur_listed = vim.api.nvim_get_option_value("buflisted", { buf = cur_buf })
  if not cur_listed then
    pcall(vim.api.nvim_buf_delete, cur_buf, { force = true })
  end
end, {
  desc = "delete other buffers (force)",
})

-- Insert a blank line below or above current line (do not move the cursor),
-- see https://stackoverflow.com/a/16136133/6064933
keymap.set("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line below",
})

keymap.set("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line above",
})

-- Move the cursor based on physical lines, not the actual lines.
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
-- keymap.set("n", "^", "g^")
-- keymap.set("n", "0", "g0")

-- Do not include white space characters when using $ in visual mode,
-- see https://vi.stackexchange.com/q/12607/15292
keymap.set("x", "$", "g_")

-- Go to start or end of line easier
-- keymap.set({ "n", "x" }, "H", "^")
-- keymap.set({ "n", "x" }, "L", "g_")

-- Continuous visual shifting (does not exit Visual mode), `gv` means
-- to reselect previous visual area, see https://superuser.com/q/310417/736190
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")

-- Edit and reload nvim config file quickly
keymap.set("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", {
  silent = true,
  desc = "open init.lua",
})

keymap.set("n", "<leader>sv", function()
  vim.cmd("ReloadConfig")
end, {
  silent = true,
  desc = "reload init.lua",
})

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
-- keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
--   expr = true,
--   desc = "reselect last pasted area",
-- })

-- Always use very magic mode for searching
-- keymap.set("n", "/", [[/\v]])

-- Search in selected region
-- xnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>

-- Change current working directory locally and print cwd after that,
-- see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
-- Note: remapped from <leader>cd to <leader>lc to free <leader>c prefix for cscope
keymap.set("n", "<leader>lc", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd (lcd)" })

-- Use Esc or C-e to quit builtin terminal
keymap.set("t", "<Esc>", [[<c-\><c-n>]])
keymap.set("t", "<C-e>", [[<c-\><c-n>]])

-- <leader>tt is handled by toggleterm.nvim (floating terminal)

-- Toggle spell checking
keymap.set("n", "<F12>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
keymap.set("i", "<F12>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')

-- Remove trailing whitespace characters
-- keymap.set("n", "<leader><space>", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" }) <-- This code need to be fixed as follow.
keymap.set("n", "<leader><space>", function()
  vim.fn["utils#StripTrailingWhitespace"]()
end, { desc = "remove trailing space" })

-- Copy entire buffer.
keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Toggle cursor column
keymap.set("n", "<leader>cl", "<cmd>call utils#ToggleCursorCol()<cr>", { desc = "toggle cursor column" })

-- Move current line up and down
keymap.set("n", "<A-k>", '<cmd>call utils#SwitchLine(line("."), "up")<cr>', { desc = "move line up" })
keymap.set("n", "<A-j>", '<cmd>call utils#SwitchLine(line("."), "down")<cr>', { desc = "move line down" })

-- Move current visual-line selection up and down
keymap.set("x", "<A-k>", '<cmd>call utils#MoveSelection("up")<cr>', { desc = "move selection up" })
keymap.set("x", "<A-j>", '<cmd>call utils#MoveSelection("down")<cr>', { desc = "move selection down" })
keymap.set("x", "<A-h>", '<cmd>call utils#MoveSelection("left")<cr>', { desc = "move selection left" })
keymap.set("x", "<A-l>", '<cmd>call utils#MoveSelection("right")<cr>', { desc = "move selection right" })

-- keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })
-- keymap.set("x", "P", [["_dP]], { desc = "Paste without overwriting register" })
-- vim.keymap.set('x', 'p', [["_d"0P]], { desc = 'Visual paste from "0; keep registers' })
-- vim.keymap.set('x', 'P', [["_d"0P]], { desc = 'Visual paste from "0; keep registers' })


-- Go to a certain buffer
keymap.set("n", "gb", '<cmd>call buf_utils#GoToBuffer(v:count, "forward")<cr>', {
  desc = "go to buffer (forward)",
})
keymap.set("n", "gB", '<cmd>call buf_utils#GoToBuffer(v:count, "backward")<cr>', {
  desc = "go to buffer (backward)",
})

-- Switch windows
keymap.set("n", "<C-h>", "<c-w>h")
keymap.set("n", "<C-l>", "<C-W>l")
keymap.set("n", "<C-k>", "<C-W>k")
keymap.set("n", "<C-j>", "<C-W>j")

-- Resize windows with arrow keys
-- Up/Down adjust height; Left/Right adjust width
keymap.set("n", "<C-Up>",    "<cmd>resize +2<CR>",          { silent = true, desc = "increase window height" })
keymap.set("n", "<C-Down>",  "<cmd>resize -2<CR>",          { silent = true, desc = "decrease window height" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { silent = true, desc = "increase window width" })
keymap.set("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { silent = true, desc = "decrease window width" })

-- Text objects for URL
keymap.set({ "x", "o" }, "iu", "<cmd>call text_obj#URL()<cr>", { desc = "URL text object" })

-- Text objects for entire buffer
-- keymap.set({ "x", "o" }, "iB", ":<C-U>call text_obj#Buffer()<cr>", { desc = "buffer text object" })

-- Do not move my cursor when joining lines.
keymap.set("n", "J", function()
  vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, {
  desc = "join lines without moving cursor",
})

keymap.set("n", "gJ", function()
  -- we must use `normal!`, otherwise it will trigger recursive mapping
  vim.cmd([[
      normal! mzgJ`z
      delmarks z
    ]])
end, {
  desc = "join lines without moving cursor",
})

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u")
end

-- insert semicolon in the end
keymap.set("i", "<A-;>", "<Esc>miA;<Esc>`ia")

-- Go to the beginning and end of current line in insert mode quickly
keymap.set("i", "<C-A>", "<HOME>")
keymap.set("i", "<C-E>", "<END>")

-- Go to beginning of command in command-line mode
keymap.set("c", "<C-A>", "<HOME>")

-- Note: remapped from <leader>cb to <leader>ub to free <leader>c prefix for cscope
keymap.set("n", "<leader>ub", function()
  local cnt = 0
  local blink_times = 7
  local timer = uv.new_timer()
  if timer == nil then
    return
  end

  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      vim.cmd([[
      set cursorcolumn!
      set cursorline!
    ]])

      if cnt == blink_times then
        timer:close()
      end

      cnt = cnt + 1
    end)
  )
end, { desc = "show cursor" })

------------------------------ My config ------------------------------------------
-----------------
-- Normal mode --
-----------------

-- Disable highlight when <leader><cr> is pressed
keymap.set({ "n" }, "<leader><cr>", "<cmd>nohlsearch<cr>", { desc = "clear search highlight" })

-- tabufline
keymap.set({ "n" }, "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

-- Useful mappings for managing tabs
keymap.set({ "n" }, "<leader>tn", "<cmd>tabnew<CR>",   { desc = "tab: new" })
keymap.set({ "n" }, "<leader>tc", "<cmd>tabclose<CR>", { desc = "tab: close" })
-- keymap.set({ "n" }, "<leader>tm", "<cmd>tabmove<CR>")

-- next and prev tab
keymap.set({ "n" }, "<F7>", "<cmd>tabNext<CR>",   { desc = "tab: prev" })
keymap.set({ "n" }, "<F8>", "<cmd>tabnext<CR>",   { desc = "tab: next" })
keymap.set({ "n" }, "<F6>", "<cmd>tabclose<CR>",  { desc = "tab: close" })

-- Opens a new tab with the current buffer's path
-- Super useful when editing files in the same directory
keymap.set({ "n" }, "<leader>te", function () return ':tabedit ' ..  vim.fn.expand '%:p:h' .. '/' end, { expr = true })

keymap.set("n", "<A-l>", "xp")
keymap.set("n", "<A-h>", "x2hp")

-----------------
-- Insert mode --
-----------------
-- Mapping jj to <Esc> in Insert Mode, return Normal mode
-- keymap.set({ "i" }, "jj", "<ESC>")
-- Vim built-ins available in insert mode without any mapping:
--   <C-w>  delete word left
--   <C-u>  delete to line start

keymap.set("i", "<C-h>", "<BS>",  { desc = "delete char left" })
keymap.set("i", "<C-l>", "<Del>", { desc = "delete char right" })

-- Swallow <C-j> and <C-k> in plain insert mode so they don't insert garbage
-- (^@ null byte for C-j, digraph prompt for C-k). <Nop> is the correct
-- fallback even if UltiSnips/nvim-cmp fail to load — silent is better than
-- garbage. The plugins override these at higher priority when active.
keymap.set("i", "<C-j>", "<Nop>", { desc = "reserved for UltiSnips expand/jump" })
keymap.set("i", "<C-k>", "<Nop>", { desc = "reserved for UltiSnips jump back" })

-- Toggle fold method between expr (treesitter) and manual
-- Use <leader>fm to freeze folds after opening them so edits don't re-fold
keymap.set("n", "<leader>fm", function()
  if vim.o.foldmethod == "expr" then
    vim.o.foldmethod = "manual"
    vim.notify("Foldmethod: manual (folds frozen)", vim.log.levels.INFO)
  else
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.notify("Foldmethod: expr (treesitter)", vim.log.levels.INFO)
  end
end, { desc = "toggle fold method expr/manual" })

-- ─── Ack (mileszs/ack.vim) ───────────────────────────────────────────────────
-- Full config + keymaps live in lua/config/ack.lua (loaded lazily).
-- Keymaps are registered there so they only bind once the plugin is sourced.
-- Documented here for which-key visibility:
--   <leader>ak   search word under cursor
--   <leader>akk  open Ack prompt
--   v<leader>ak  search visual selection

-- ─── Quickfix ────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>co", "<cmd>copen<CR>",  { desc = "open quickfix list" })
keymap.set("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "close quickfix list" })
keymap.set("n", "]q",         "<cmd>cnext<CR>",  { desc = "next quickfix item" })
keymap.set("n", "[q",         "<cmd>cprev<CR>",  { desc = "prev quickfix item" })
keymap.set("n", "]Q",         "<cmd>clast<CR>",  { desc = "last quickfix item" })
keymap.set("n", "[Q",         "<cmd>cfirst<CR>", { desc = "first quickfix item" })

-- ─── Colorscheme picker ──────────────────────────────────────────────────────
keymap.set("n", "<leader>uc", function()
  local color_scheme = require("colorschemes")
  local keys = vim.tbl_keys(color_scheme.colorscheme_conf)
  table.sort(keys)
  require("fzf-lua").fzf_exec(keys, {
    prompt = "Colorscheme> ",
    winopts = { height = 0.4, width = 0.3, preview = { hidden = "hidden" } },
    actions = {
      ["default"] = function(selected)
        if selected[1] then color_scheme.select_colorscheme(selected[1]) end
      end,
    },
  })
end, { desc = "pick colorscheme" })

keymap.set("n", "<leader>un", function() Snacks.notifier.show_history() end,
  { desc = "show notification history" })

-- ─── Format on save toggle ───────────────────────────────────────────────────
-- conform.nvim has format_on_save disabled by default (vim.g.format_on_save is nil).
-- The format_on_save callback in plugin_specs.lua checks this flag on every save.
keymap.set("n", "<leader>tf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify("Format on save: " .. (vim.g.format_on_save and "ON" or "OFF"), vim.log.levels.INFO)
end, { desc = "toggle format on save" })
