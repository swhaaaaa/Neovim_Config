scriptencoding utf-8

" Load plugins via Lua
lua require('plugin_specs')

" Short aliases for Lazy commands
call utils#Cabbrev('pi',  'Lazy install')
call utils#Cabbrev('pud', 'Lazy update')
call utils#Cabbrev('pc',  'Lazy clean')
call utils#Cabbrev('ps',  'Lazy sync')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                   Plugin Settings (VimScript)           "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""" vim-mundo
let g:mundo_verbose_graph = 0
let g:mundo_width = 80

"""" better-escape.vim
" interval is set to 175ms in lua/config/better_escape.lua (init phase)

"""" vim-matchup
let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_timeout = 100
let g:matchup_matchparen_insert_timeout = 30
let g:matchup_override_vimtex = 1
let g:matchup_delim_noskips = 0
let g:matchup_matchparen_offscreen = {'method': 'popup'}
