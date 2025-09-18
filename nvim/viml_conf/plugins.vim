scriptencoding utf-8

" Plugin specification and lua stuff
lua require('plugin_specs')
" lua require('plugin_specs_one')

" Use short names for common plugin manager commands to simplify typing.
" To use these shortcuts: first activate command line with `:`, then input the
" short alias, e.g., `pi`, then press <space>, the alias will be expanded to
" the full command automatically.
call utils#Cabbrev('pi', 'Lazy install')
call utils#Cabbrev('pud', 'Lazy update')
call utils#Cabbrev('pc', 'Lazy clean')
call utils#Cabbrev('ps', 'Lazy sync')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      configurations for vim script plugin                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



" set guifont=Iosevka\ Nerd\ Font:h18
" set guifont=Consolas

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      hexmode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:hexmode_patterns = '*.bin,*.exe,*.dat,*.o'
" let g:hexmode_xxd_options = '-g 1'
 
