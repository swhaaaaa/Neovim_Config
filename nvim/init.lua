-- Speed up startup via bytecode cache
vim.loader.enable()

local utils = require("utils")

-- Minimum supported version (nvim-treesitter main branch requires 0.12+)
local min_version = "0.12.0"
utils.is_compatible_version(min_version)

local config_dir = vim.fn.stdpath("config")
---@cast config_dir string

-- Core settings (must come first)
require("globals")

-- Vim options
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))

-- Autocommands
require("custom-autocmd")

-- Custom commands
require("custom-commands")

-- Key mappings
require("mappings")

-- Plugin manager + all plugins
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/plugins.vim"))

-- Diagnostic configuration
require("diagnostic-conf")

-- Colorscheme
local color_scheme = require("colorschemes")
-- Change "everforest" to any key in colorschemes.lua, or call rand_colorscheme()
color_scheme.select_colorscheme("everforest")
