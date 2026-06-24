local M = {}

M.get_default_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- required by nvim-ufo
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- tell servers the client supports cmp-nvim-lsp's extensions (snippet
  -- completions, resolveSupport, etc.) so e.g. clangd/pyright/lua_ls return
  -- richer completion items instead of plain text. default_capabilities()
  -- only returns a textDocument.completion fragment, so deep-merge it in
  -- rather than replacing — replacing would drop foldingRange above.
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end

  return capabilities
end

return M
