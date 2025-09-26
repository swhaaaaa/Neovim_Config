local g = vim.g
-- We can set the configuration with LSP and Vista later.
-- 優先用 LSP，沒有就 fallback 到 ctags
g.vista_default_executive = "nvim_lsp"
g.vista_executive_for = {
  markdown = "ctags",
  sh       = "ctags",
}

-- ctags 設定（建議安裝 universal-ctags）
g.vista_ctags_cmd = "ctags"
g.vista_ctags_args =
  "--fields=+niazS --extras=+q --c-kinds=+p --c++-kinds=+px --sort=no"

-- 外觀
g["vista#renderer#enable_icon"] = 1   -- 需要 Nerd Font + devicons
g.vista_icon_indent = { "╰─▸ ", "├─▸ " }
g.vista_sidebar_position = "vertical botright"
g.vista_disable_statusline = 1
g.vista_fzf_preview = { "right:50%" } -- 如果有 fzf/skim

-- 顏色微調
vim.api.nvim_set_hl(0, "VistaKind",   { link = "Type" })
vim.api.nvim_set_hl(0, "VistaScope",  { link = "Function" })
vim.api.nvim_set_hl(0, "VistaTag",    { link = "Identifier" })
vim.api.nvim_set_hl(0, "VistaLineNr", { link = "LineNr" })

