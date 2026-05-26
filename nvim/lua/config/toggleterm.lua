local ok, toggleterm = pcall(require, "toggleterm")
if not ok then return end

toggleterm.setup {
  direction  = "float",
  float_opts = { border = "curved" },
  shade_terminals = false,
}

-- Exit terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit terminal mode" })
