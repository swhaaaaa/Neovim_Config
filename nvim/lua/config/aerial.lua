local ok, aerial = pcall(require, "aerial")
if not ok then return end

aerial.setup {
  backends = { "lsp", "treesitter", "markdown", "man" },

  layout = {
    max_width         = { 60, 0.3 },
    min_width         = 20,
    default_direction = "prefer_right",
    placement         = "window",
    resize_to_content = true,
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

  -- mini.icons.tweak_lsp_kind() prepends icon glyphs + space to every
  -- vim.lsp.protocol.SymbolKind entry (e.g. "Class" → "󰌗 Class").
  -- Aerial reads SymbolKind for symbol.kind, so get_highlight receives the
  -- mangled string. Fix: extract only the trailing word.
  get_highlight = function(symbol, is_icon, _)
    local kind = (symbol.kind or ""):match("[A-Za-z]+$") or "Normal"
    return "Aerial" .. kind .. (is_icon and "Icon" or "")
  end,
}

-- mini.icons.tweak_lsp_kind() causes aerial's get_icon to receive mangled
-- kind strings ("󰌗 Class"), which then get passed verbatim to
-- mini_icons.get("lsp", ...) and M.default_icons[...], both of which fail
-- and return "?". Fix: wrap get_icon to strip the glyph prefix first.
local aerial_cfg_ok, aerial_cfg = pcall(require, "aerial.config")
if aerial_cfg_ok then
  local orig_get_icon = aerial_cfg.get_icon
  ---@diagnostic disable-next-line: duplicate-set-field
  aerial_cfg.get_icon = function(bufnr, kind, collapsed)
    local clean = (kind or ""):match("[A-Za-z]+$") or kind
    return orig_get_icon(bufnr, clean, collapsed)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "aerial",
  callback = function()
    vim.wo.wrap = false
  end,
  desc = "No wrap in aerial — resize_to_content handles long names",
})

vim.keymap.set("n", "<leader>ao", "<cmd>AerialToggle<CR>",
  { silent = true, desc = "aerial: toggle symbol outline" })
