local api = vim.api

-- Format current buffer via conform.nvim (if available)
api.nvim_create_user_command("Format", function(args)
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format { bufnr = args.buf, lsp_fallback = true }
  else
    vim.lsp.buf.format { async = false }
  end
end, { desc = "Format current buffer" })

-- Show LSP info for current buffer
api.nvim_create_user_command("LspInfo2", function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.WARN)
    return
  end
  local names = vim.tbl_map(function(c) return c.name end, clients)
  vim.notify("LSP: " .. table.concat(names, ", "), vim.log.levels.INFO)
end, { desc = "Show active LSP clients" })

-- Reload nvim config
api.nvim_create_user_command("ReloadConfig", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload init.lua" })
