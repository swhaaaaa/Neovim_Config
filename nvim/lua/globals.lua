local fn = vim.fn
local api = vim.api
local g = vim.g
local cmd = vim.cmd

local utils = require("utils")

------------------------------------------------------------------------
--                          custom variables                          --
------------------------------------------------------------------------
g.is_win = (utils.has("win32") or utils.has("win64")) and true or false
g.is_linux = (utils.has("unix") and (not utils.has("macunix"))) and true or false
g.is_mac = utils.has("macunix") and true or false

g.logging_level = "info"
--g.logging_level = "debug"

------------------------------------------------------------------------
--                         builtin variables                          --
------------------------------------------------------------------------
g.loaded_perl_provider = 0 -- Disable perl provider
g.loaded_ruby_provider = 0 -- Disable ruby provider
g.loaded_node_provider = 0 -- Disable node provider
g.did_install_default_menus = 1 -- do not load menu

if utils.executable("python3") then
  if g.is_win then
    g.python3_host_prog = fn.substitute(fn.exepath("python3"), ".exe$", "", "g")
  else
    g.python3_host_prog = fn.exepath("python3")
  end
else
  api.nvim_err_writeln("Python3 executable not found! You must install Python3 and set its PATH correctly!")
  return
end

-- Custom mapping <leader> (see `:h mapleader` for more info)
g.mapleader = ","

-- Enable highlighting for lua HERE doc inside vim script
g.vimsyn_embed = "l"

-- Use English as main language
cmd([[language en_US.UTF-8]])

-- Disable loading certain plugins

-- For nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
-- Whether to load netrw by default, see https://github.com/bling/dotvim/issues/4
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.netrw_liststyle = 3
if g.is_win then
  g.netrw_http_cmd = "curl --ssl-no-revoke -Lo"
end

-- Do not load tohtml.vim
g.loaded_2html_plugin = 1

-- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
-- related to checking files inside compressed files)
g.loaded_zipPlugin = 1
g.loaded_gzip = 1
g.loaded_tarPlugin = 1

-- Do not load the tutor plugin
g.loaded_tutor_mode_plugin = 1

-- Do not use builtin matchit.vim and matchparen.vim since we use vim-matchup
g.loaded_matchit = 1
g.loaded_matchparen = 1

-- Disable sql omni completion, it is broken.
g.loaded_sql_completion = 1
