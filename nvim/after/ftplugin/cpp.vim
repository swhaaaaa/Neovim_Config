set commentstring=//\ %s

" Disable inserting comment leader after hitting o or O or <Enter>
set formatoptions-=o
set formatoptions-=r

nnoremap <silent> <buffer> <F9> :call <SID>compile_run_cpp()<CR>

function! s:compile_run_cpp() abort
  " Full path, not the `~`-abbreviated `:~` form: shellescape() quotes the
  " whole path, which disables the shell's tilde expansion, so a literal
  " '~' would be searched for as a real directory named "~" instead of
  " being expanded to $HOME.
  let src_path = expand('%:p')
  let src_noext = expand('%:p:r')
  " The building flags
  let _flag = '-Wall -Wextra -std=c++11 -O2'

  if executable('clang++')
    let prog = 'clang++'
  elseif executable('g++')
    let prog = 'g++'
  else
    echoerr 'No C++ compiler found on the system!'
    return
  endif

  " run_in_terminal() uses termopen() directly instead of `:term {cmd}`,
  " which would re-parse this string as an Ex command line and break on
  " any space in the path (even inside shellescape()'d quotes).
  let cmd = printf('%s %s %s -o %s && %s',
        \ prog, _flag, shellescape(src_path), shellescape(src_noext), shellescape(src_noext))
  call v:lua.require('utils').run_in_terminal(20, cmd)
endfunction
