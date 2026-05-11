--- Colorscheme configuration and loader.
--- Uses only the curated set defined in plugin_specs.lua.
local M = {}

local use_theme = vim.cmd.colorscheme

-- Map of scheme key → setup function
M.colorscheme_conf = {
  everforest = function()
    vim.g.everforest_background = "hard"
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_better_performance = 1
    use_theme("everforest")
  end,
  gruvbox_material = function()
    vim.g.gruvbox_material_foreground = "original"
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_better_performance = 1
    use_theme("gruvbox-material")
  end,
  sonokai = function()
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_better_performance = 1
    use_theme("sonokai")
  end,
  tokyonight = function()
    require("tokyonight").setup { style = "night" }
    use_theme("tokyonight")
  end,
  catppuccin = function()
    require("catppuccin").setup { flavour = "mocha" }
    use_theme("catppuccin")
  end,
  kanagawa = function()
    use_theme("kanagawa-dragon")
  end,
  nightfox = function()
    use_theme("carbonfox")
  end,
}

--- Load a random colorscheme from the configured list.
M.rand_colorscheme = function()
  local keys = vim.tbl_keys(M.colorscheme_conf)
  math.randomseed(os.time())
  local scheme = keys[math.random(#keys)]
  M.colorscheme_conf[scheme]()
end

--- Load a specific colorscheme by key name.
---@param scheme_name string Key in M.colorscheme_conf
M.select_colorscheme = function(scheme_name)
  local fn = M.colorscheme_conf[scheme_name]
  if not fn then
    vim.notify("Unknown colorscheme: " .. scheme_name, vim.log.levels.ERROR)
    return
  end
  fn()
  vim.notify("Colorscheme: " .. (vim.g.colors_name or scheme_name), vim.log.levels.INFO)
end

return M
