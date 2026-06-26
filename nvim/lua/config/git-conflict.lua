local ok, git_conflict = pcall(require, "git-conflict")
if not ok then return end
git_conflict.setup {}

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("git_conflict_resolved", { clear = true }),
  pattern = "GitConflictResolved",
  callback = function()
    -- clear qf list
    vim.fn.setqflist({}, "r")

    -- reopen it?
    vim.cmd([[silent! GitConflictListQf]])
  end,
})
