local ok, aerial = pcall(require, "aerial")
if not ok then return end

aerial.setup {
  backends = { "lsp", "treesitter", "markdown", "man" },

  layout = {
    max_width         = { 40, 0.2 },
    min_width         = 20,
    default_direction = "prefer_right",
    placement         = "window",
  },

  -- false = show all symbol kinds; the default whitelist excludes Namespace
  -- and Variable which are the dominant kinds in C++ / sdbusplus files.
  filter_kind        = false,

  show_guides        = true,
  -- "global" tracks all buffers so symbols are ready when the window opens.
  -- "window" only attaches when the aerial panel is visible — causes "No symbols"
  -- when the panel is first opened because LSP already attached before aerial did.
  attach_mode        = "global",
  highlight_on_hover = false,
  highlight_on_jump  = false,

  -- E5248 fix: mini.icons.tweak_lsp_kind() prepends icon glyphs + space to
  -- every vim.lsp.protocol.SymbolKind entry (e.g. "Class" → "󰌗 Class").
  -- Aerial reads SymbolKind to populate symbol.kind, so it gets "󰌗 Class".
  -- Naively doing "Aerial" .. symbol.kind produces "Aerial󰌗 Class" which
  -- contains non-ASCII and space — E5248 invalid group name characters.
  -- Fix: extract only the trailing letters word from symbol.kind.
  get_highlight = function(symbol, is_icon, _)
    local kind = (symbol.kind or ""):match("[A-Za-z]+$") or "Normal"
    return "Aerial" .. kind .. (is_icon and "Icon" or "")
  end,
}

vim.keymap.set("n", "<leader>ao", "<cmd>AerialToggle<CR>",
  { silent = true, desc = "aerial: toggle symbol outline" })
