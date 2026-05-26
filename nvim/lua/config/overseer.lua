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

local map = vim.keymap.set
map("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "overseer: toggle task list" })
map("n", "<leader>or", "<cmd>OverseerRun<CR>",    { desc = "overseer: run task template" })
map("n", "<leader>oR", "<cmd>OverseerShell<CR>",  { desc = "overseer: run shell command" })
