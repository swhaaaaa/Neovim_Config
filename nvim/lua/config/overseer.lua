local ok, overseer = pcall(require, "overseer")
if not ok then return end

overseer.setup {
  task_list = {
    direction  = "bottom",
    min_height = 10,
    max_height = 20,
    bindings = {
      ["<CR>"]  = "RunAction",
      ["q"]     = "Close",
      ["<C-l>"] = "IncreaseDetail",
      ["<C-h>"] = "DecreaseDetail",
    },
  },
}
