-- nvim-treesitter new API (v1.0+, no nvim-treesitter.configs module)
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end
ts.setup()

-- The nvim-treesitter main branch no longer enables highlighting by itself;
-- each buffer must call vim.treesitter.start(). Without this only filetypes
-- whose *built-in* ftplugin starts it (lua, help, query, ...) got Treesitter
-- highlighting, while c/cpp/python/rust/... silently fell back to regex syntax.
-- pcall: no-op when no parser is installed for the filetype. Large files
-- (custom-autocmd.lua) are skipped automatically: they are opened with
-- eventignore=all, so FileType never fires for them.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
  desc = "enable Treesitter highlighting when a parser is available",
})

-- Auto-install parsers after lazy finishes loading
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  group = vim.api.nvim_create_augroup("treesitter_install_parsers", { clear = true }),
  callback = function()
    local parsers = {
      "bash", "c", "cpp", "lua", "python", "rust",
      "vim", "vimdoc", "json", "toml", "yaml",
      "markdown", "markdown_inline",
    }
    for _, lang in ipairs(parsers) do
      pcall(vim.treesitter.language.add, lang)
    end
    -- Use the TSInstall command which is always available
    vim.cmd("TSInstall " .. table.concat(parsers, " "))
  end,
})
