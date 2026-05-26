local ok, live_command = pcall(require, "live-command")
if not ok then return end
live_command.setup {
  enable_highlighting = true,
  inline_highlighting = true,
  commands = {
    Norm = { cmd = "norm" },
  },
}

vim.cmd("cnoreabbrev norm Norm")
