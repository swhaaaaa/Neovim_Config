local ok, bqf = pcall(require, "bqf")
if not ok then return end
bqf.setup {
  auto_resize_height = false,
  preview = {
    auto_preview = false,
  },
}
