local ok, git_conflict = pcall(require, "git-conflict")
if not ok then return end
git_conflict.setup {}

vim.api.nvim_create_autocmd("User", {
  pattern = "GitConflictResolved",
  callback = function()
    -- clear qf list
    vim.fn.setqflist({}, "r")

    -- reopen it?
    vim.cmd([[silent! GitConflictListQf]])
  end,
})
