local utils = require("utils")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_buf_conf", { clear = true }),
  callback = function(event_context)
    local client = vim.lsp.get_client_by_id(event_context.data.client_id)
    -- vim.print(client.name, client.server_capabilities)

    if not client then
      return
    end

    local bufnr = event_context.buf

    -- Mappings.
    local map = function(mode, l, r, opts)
      opts = opts or {}
      opts.silent = true
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "gd", function()
      vim.lsp.buf.definition {
        on_list = function(options)
          -- custom logic to avoid showing multiple definition when you use this style of code:
          -- `local M.my_fn_name = function() ... end`.
          -- See also post here: https://www.reddit.com/r/neovim/comments/19cvgtp/any_way_to_remove_redundant_definition_in_lua_file/

          -- vim.print(options.items)
          local unique_defs = {}
          local def_loc_hash = {}

          -- each item in options.items contain the location info for a definition provided by LSP server
          for _, def_location in pairs(options.items) do
            -- use filename and line number to uniquelly indentify a definition,
            -- we do not expect/want multiple definition in single line!
            local hash_key = def_location.filename .. def_location.lnum

            if not def_loc_hash[hash_key] then
              def_loc_hash[hash_key] = true
              table.insert(unique_defs, def_location)
            end
          end

          options.items = unique_defs

          -- set the location list
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.fn.setloclist(0, {}, " ", options)

          -- open the location list when we have more than 1 definitions found,
          -- otherwise, jump directly to the definition
          if #options.items > 1 then
            vim.cmd.lopen()
          else
            vim.cmd([[silent! lfirst]])
          end
        end,
      }
    end, { desc = "go to definition" })
    map("n", "<C-]>", vim.lsp.buf.definition)
    map("n", "K", function()
      vim.lsp.buf.hover {
        border = "single",
        max_height = 20,
        max_width = 130,
        close_events = { "CursorMoved", "BufLeave", "WinLeave", "LspDetach" },
      }
    end)
    -- <C-k> reserved for window/tmux navigation (smart-splits.nvim, see plugin_specs.lua)
    -- signature help moved to <leader>sh
    map("n", "<leader>sh", function()
      vim.lsp.buf.signature_help { border = "single" }
    end, { desc = "LSP: signature help" })
    map("n", "<leader>rn", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { expr = true, desc = "LSP: rename symbol (inc-rename)" })
    -- Note: <leader>ca → <leader>la — cscope_maps.nvim's own <leader>ca
    -- ("find symbol assignments") lives under the cscope-reserved <leader>c
    -- prefix (see cscope.lua); this buffer-local map was silently shadowing
    -- it in LSP-attached buffers. Moved into the LSP peek (glance) group.
    map("n", "<leader>la", vim.lsp.buf.code_action,  { desc = "LSP: code action" })
    -- Note: <leader>wa/wr/wl → <leader>Wa/Wr/Wl — <leader>w is also bound
    -- directly to "save buffer" (mappings.lua). Sharing that as a prefix made
    -- every <leader>w in an LSP-attached buffer wait out 'timeoutlen' (500ms)
    -- before saving, since Neovim couldn't tell it apart from <leader>wa/wr/wl
    -- without waiting. Capital W shares no prefix with lowercase w, so both
    -- fire instantly.
    map("n", "<leader>Wa", vim.lsp.buf.add_workspace_folder,    { desc = "LSP: add workspace folder" })
    map("n", "<leader>Wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP: remove workspace folder" })
    map("n", "<leader>Wl", function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, { desc = "LSP: list workspace folders" })

    -- Toggle inlay hints for the current buffer (works for all LSP clients).
    -- clangd_extensions.lua had a global <leader>ih that only registered on c/cpp;
    -- this buffer-local version works for lua_ls, pyright, rust_analyzer, etc.
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr },
          { bufnr = bufnr }
        )
        local state = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr } and "enabled" or "disabled"
        vim.notify("Inlay hints " .. state, vim.log.levels.INFO)
      end, { desc = "LSP: toggle inlay hints" })
    end

    -- Set some key bindings conditional on server capabilities
    -- Disable ruff hover feature in favor of Pyright
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end

    -- vim-illuminate already highlights references via LSP/treesitter/regex
    -- with a configurable delay and proper provider priority.  A second
    -- document_highlight path here (one per LspAttach call, shared augroup
    -- name) races when multiple clients attach and produces double-highlight
    -- artifacts.  Removed in favour of vim-illuminate alone.
  end,
  nested = true,
  desc = "Configure buffer keymap and behavior based on LSP",
})

-- Enable lsp servers when they are available

local capabilities = require("lsp_utils").get_default_capabilities()

-- Neovim 0.11+: use bracket syntax for vim.lsp.config
vim.lsp.config["*"] = {
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 500,
  },
}

-- A mapping from lsp server name to the executable name
local enabled_lsp_servers = {
--  pyright = "delance-langserver",
  pyright = "pyright-langserver",
  ruff = "ruff",
  lua_ls = "lua-language-server",
  clangd = "clangd",
  vimls = "vim-language-server",
  bashls = "bash-language-server",
  yamlls = "yaml-language-server",
  rust_analyzer = "rust-analyzer",
}

for server_name, lsp_executable in pairs(enabled_lsp_servers) do
  if utils.executable(lsp_executable) then
    vim.lsp.enable(server_name)
  else
    local msg = string.format(
      "Executable '%s' for server '%s' not found! Server will not be enabled",
      lsp_executable,
      server_name
    )
    vim.notify(msg, vim.log.levels.WARN, { title = "Nvim-config" })
  end
end
