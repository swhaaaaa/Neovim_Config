require("hex").setup({})  -- defaults are fine

-- auto-enter hex view for common binary extensions
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.bin", "*.dat", "*.o", "*.so", "*.elf", "*.img", "*.ima", "*.rom" },
  callback = function() require("hex").toggle() end,
})


