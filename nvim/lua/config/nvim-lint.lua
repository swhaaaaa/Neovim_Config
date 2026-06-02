local ok, lint = pcall(require, "lint")
if not ok then return end

lint.linters_by_ft = {
  -- shellcheck catches issues bashls misses (SC codes, portability, etc.)
  sh   = { "shellcheck" },
  bash = { "shellcheck" },
  -- Python: ruff (LSP) and pyright already cover linting/types; omitted here.
  -- C/C++: clangd covers diagnostics; add "clangtidy" here if you want extra checks.
}

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
