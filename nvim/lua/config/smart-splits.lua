local smart_splits = require("smart-splits")

smart_splits.setup {
  ignored_filetypes = { "nofile", "quickfix", "prompt" },
  ignored_buftypes = { "nofile" },
}

vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left,  { desc = "window/tmux: move left" })
vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down,  { desc = "window/tmux: move down" })
vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up,    { desc = "window/tmux: move up" })
vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right, { desc = "window/tmux: move right" })
