local ok, persistence = pcall(require, "persistence")
if not ok then return end

persistence.setup {
  dir = vim.fn.stdpath("state") .. "/sessions/",
}

local map = vim.keymap.set
map("n", "<leader>ss", function() persistence.load() end,              { desc = "session: restore for cwd" })
map("n", "<leader>sl", function() persistence.load({ last = true }) end, { desc = "session: restore last" })
map("n", "<leader>sd", function() persistence.stop() end,              { desc = "session: stop (don't save on exit)" })
