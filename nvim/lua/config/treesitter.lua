-- nvim-treesitter new API (v1.0+, no nvim-treesitter.configs module)
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end
ts.setup()

-- Auto-install parsers after lazy finishes loading
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    local parsers = {
      "bash", "c", "cpp", "lua", "python",
      "vim", "vimdoc", "json", "toml", "yaml",
      "markdown", "markdown_inline",
    }
    for _, lang in ipairs(parsers) do
      pcall(vim.treesitter.language.add, lang)
    end
    -- Use the TSInstall command which is always available
    vim.cmd("TSInstall! " .. table.concat(parsers, " "))
  end,
})
