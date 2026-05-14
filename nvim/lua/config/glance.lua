local glance = require("glance")

glance.setup {
  height = 25,
  border = {
    enable = true,
  },
}

-- <leader>gd is taken by fugitive (Gdiffsplit), so use <leader>l prefix for LSP peek
vim.keymap.set("n", "<leader>ld", "<cmd>Glance definitions<cr>",     { desc = "LSP: peek definitions" })
vim.keymap.set("n", "<leader>lr", "<cmd>Glance references<cr>",      { desc = "LSP: peek references" })
vim.keymap.set("n", "<leader>li", "<cmd>Glance implementations<cr>", { desc = "LSP: peek implementations" })
