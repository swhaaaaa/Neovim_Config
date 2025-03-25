-- Enhance nvim start up
vim.loader.enable()

local utils = require("utils")

local expected_version = "0.10.4"
utils.is_compatible_version(expected_version)

-- some global settings
require("globals")

-- load options
require('options')

-- load keymappings
require('keymaps')

-- load autocmds
require('custom-autocmd')

-- Plugin specification and lua stuff
require("plugin_specs")

local config_dir = vim.fn.stdpath("config")

-- setting options in nvim
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))

vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/plugins.vim"))

-- Set colorscheme
require('colorscheme')

-- Set LSP
require('lsp')

-- Manual Installation Clip Tool
-- sudo apt install xclip -y

-- Manual Installation clangd server for LSP
-- sudo apt install clang -y
