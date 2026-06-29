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

-- ── Extra clangd keymaps (buffer-local — only active where clangd is attached) ─
-- <leader>ih is registered per-buffer in lsp.lua for all LSP clients.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("clangd_extensions_maps", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "clangd" then return end
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "<leader>as", "<cmd>ClangdSwitchSourceHeader<CR>",
      vim.tbl_extend("force", opts, { desc = "clangd: switch source/header" }))
    vim.keymap.set("n", "<leader>ai", "<cmd>ClangdSymbolInfo<CR>",
      vim.tbl_extend("force", opts, { desc = "clangd: symbol info" }))
    vim.keymap.set("n", "<leader>mu", "<cmd>ClangdMemoryUsage<CR>",
      vim.tbl_extend("force", opts, { desc = "clangd: memory usage" }))
    vim.keymap.set("n", "<leader>at", "<cmd>ClangdAST<CR>",
      vim.tbl_extend("force", opts, { desc = "clangd: view AST" }))
  end,
})
