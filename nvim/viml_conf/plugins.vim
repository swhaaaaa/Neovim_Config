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

""""""""""""""""""""""""""" vista settings """"""""""""""""""""""""""""""""""
let g:vista#renderer#icons = {
      \ 'member': '',
      \ }

" Do not echo message on command line
let g:vista_echo_cursor = 0
" Stay in current window when vista window is opened
let g:vista_stay_on_open = 0

nnoremap <silent> <Space>t :<C-U>Vista!!<CR>

""""""""""""""""""""""""vim-mundo settings"""""""""""""""""""""""
let g:mundo_verbose_graph = 0
let g:mundo_width = 80

nnoremap <silent> <Space>u :MundoToggle<CR>



