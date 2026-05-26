local ok, glance = pcall(require, "glance")
if not ok then return end

glance.setup {
  height = 25,
  border = {
    enable = true,
  },
}
