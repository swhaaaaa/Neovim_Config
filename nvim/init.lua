-- Enhance nvim start up
vim.loader.enable()

local utils = require("utils")

local expected_version = "0.11.3"
utils.is_compatible_version(expected_version)

local config_dir = vim.fn.stdpath("config")
---@cast config_dir string

-- some global settings
require("globals")

-- setting options in nvim
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))

-- various autocommands
require("custom-autocmd")

-- various custom commands
require("custom-commands")

-- all the user-defined mappings
require("mappings")

-- all the plugins installed and their configurations
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/plugins.vim"))

-- Set colorscheme
--require('colorscheme')
-- colorscheme settings
local color_scheme = require("colorschemes")

-- Load a random or specify colorscheme
-- color_scheme.rand_colorscheme()
color_scheme.select_colorscheme("vscode")


-- Set LSP
-- require('lsp')

-- Manual Installation Clip Tool
-- sudo apt install xclip -y

-- Manual Installation clangd server for LSP
-- sudo apt install clang -y
