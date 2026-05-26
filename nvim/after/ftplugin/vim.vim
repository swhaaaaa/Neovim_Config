" Disable inserting comment leader after hitting o or O or <Enter>
set formatoptions-=o
set formatoptions-=r

" Disable modelines for vim files: modelines re-execute each time window focus
" is lost with vim-tmux-focus-events (see
" https://github.com/tmux-plugins/vim-tmux-focus-events/issues/14)
set nomodeline
set foldmethod=expr foldexpr=utils#VimFolds(v:lnum) foldtext=utils#MyFoldText()

" Use :help command for keyword when pressing `K` in vim file,
" see `:h K` and https://stackoverflow.com/q/15867323/6064933
set keywordprg=:help

nnoremap <buffer><silent> <F9> :source %<CR>
