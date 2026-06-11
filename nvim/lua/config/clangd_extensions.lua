-- lua/config/clangd_extensions.lua
-- Enhances clangd with inlay hints, AST view, and memory usage.
-- Requires clangd >= 12.

local ok, ext = pcall(require, "clangd_extensions")
if not ok then return end

ext.setup {
  ast = {
    -- Icons for AST node roles
    role_icons = {
      type            = "",
      declaration     = "",
      expression      = "",
      specifier       = "",
      statement       = "",
      ["template argument"] = "",
    },
    kind_icons = {
      Compound      = "",
      Recovery      = "",
      TranslationUnit = "",
      PackExpansion = "",
      TemplateTypeParm = "",
      TemplateTemplateParm = "",
      TemplateParamObject = "",
    },
  },
  memory_usage = {
    border = "rounded",
  },
  symbol_info = {
    border = "rounded",
  },
}

-- ── Extra clangd keymaps ─────────────────────────────────────────────────────
-- <leader>ih is now registered per-buffer in lsp.lua for all LSP clients.
-- Switch between header and source (clangd native — faster than a.vim)
vim.keymap.set("n", "<leader>as", "<cmd>ClangdSwitchSourceHeader<CR>",
  { desc = "clangd: switch source/header" })

-- Show symbol info (type, canonical declaration)
vim.keymap.set("n", "<leader>si", "<cmd>ClangdSymbolInfo<CR>",
  { desc = "clangd: symbol info" })

-- Show memory usage breakdown of clangd
vim.keymap.set("n", "<leader>mu", "<cmd>ClangdMemoryUsage<CR>",
  { desc = "clangd: memory usage" })

-- View AST for node under cursor
vim.keymap.set("n", "<leader>at", "<cmd>ClangdAST<CR>",
  { desc = "clangd: view AST" })
