local ok, lightbulb = pcall(require, "nvim-lightbulb")
if not ok then return end

lightbulb.setup {
  autocmd = { enabled = true },
  sign = { enabled = true, text = "💡" },
  virtual_text = { enabled = false },
  float = { enabled = false },
}
