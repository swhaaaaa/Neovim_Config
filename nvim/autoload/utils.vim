" Create command alias safely, see https://stackoverflow.com/q/3878692/6064933
" The following two functions are taken from answer below on SO:
" https://stackoverflow.com/a/10708687/6064933
function! utils#Cabbrev(key, value) abort
  execute printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
        \ a:key, 1+len(a:key), <SID>Single_quote(a:value), <SID>Single_quote(a:key))
endfunction

function! s:Single_quote(str) abort
  return "'" . substitute(copy(a:str), "'", "''", 'g') . "'"
endfunction

" Custom fold expr, adapted from https://vi.stackexchange.com/a/9094/15292
function! utils#VimFolds(lnum) abort
  " get content of current line and the line below
  let l:cur_line = getline(a:lnum)
  let l:next_line = getline(a:lnum+1)

  if l:cur_line =~# '^"{'
    return '>' . (matchend(l:cur_line, '"{*') - 1)
  endif

  if l:cur_line ==# '' && (matchend(l:next_line, '"{*') - 1) == 1
    return 0
  endif

  return '='
endfunction

" Custom fold text, adapted from https://vi.stackexchange.com/a/3818/15292
" and https://vi.stackexchange.com/a/6608/15292
function! utils#MyFoldText() abort
  let l:line = getline(v:foldstart)
  let l:fold_line_num = v:foldend - v:foldstart
  let l:fold_text = substitute(l:line, '^"{\+', '', 'g')
  let l:fill_char_num = &textwidth - len(l:fold_text) - len(l:fold_line_num) - 10
  return printf('+%s%s %s (%s L)', repeat('-', 4), l:fold_text, repeat('-', l:fill_char_num), l:fold_line_num)
endfunction

" Toggle cursor column
function! utils#ToggleCursorCol() abort
  if &cursorcolumn
    set nocursorcolumn
    echo 'cursorcolumn: OFF'
  else
    set cursorcolumn
    echo 'cursorcolumn: ON'
  endif
endfunction

function! utils#SwitchLine(src_line_idx, direction) abort
  if a:direction ==# 'up'
    if a:src_line_idx == 1
        return
    endif
    move-2
  elseif a:direction ==# 'down'
    if a:src_line_idx == line('$')
        return
    endif
    move+1
  endif
endfunction

" TODO: the behavior is not correct.
function! utils#MoveSelection(direction) abort
  " Only operate when we're in any visual mode (v, V, or Ctrl-V)
  if mode() !~# 'v' && mode() !~# 'V' && mode() !=# "\<C-v>"
    return
  endif

  " Cache ends of the selection
  let l:start_line = line("'<")
  let l:end_line   = line("'>")
  let l:last_line  = line('$')

  if a:direction ==# 'down'
    " Same as: :m'>+ | `<my`>mzgv`yo`z
    if l:end_line == l:last_line
      " Can't move past EOF; just keep selection
      normal! gv
      return
    endif
    silent execute "normal! :'<,'>m'>+\<CR>"
    normal! `<my`>mzgv`yo`z

  elseif a:direction ==# 'up'
    " Same as: :m'<-2 | `>my`<mzgv`yo`z
    if l:start_line == 1
      normal! gv
      return
    endif
    silent execute "normal! :'<,'>m'<-2\<CR>"
    normal! `>my`<mzgv`yo`z

  elseif a:direction ==# 'right'
    " Exactly your mapping: xmzpmy`zlv`y
    " (shift selection one char to the right and reselect)
    normal! xmzpmy`zlv`y

  elseif a:direction ==# 'left'
    " Exactly your mapping: x2hmzpv`zl
    " (shift selection one/two chars to the left and reselect)
    normal! x2hmzpv`zl
  endif
endfunction


function! utils#Get_titlestr() abort
  let l:title_str = ''
  if g:is_linux
      let l:title_str = hostname() . '  '
  endif

  let l:buf_path = expand('%:p:~')
  let l:title_str = l:title_str . l:buf_path . '  '
  if &buflisted && l:buf_path != ""
    let l:title_str = l:title_str . strftime('%Y-%m-%d %H:%M:%S%z', getftime(expand('%')))
  endif

  return l:title_str
endfunction

" Output current time or unix timestamp in human-readable format.
function! utils#iso_time(timestamp) abort
  " Get current datetime
  if !a:timestamp
    return strftime('%Y-%m-%d %H:%M:%S%z')
  endif

  " this timestamp in expressed in milliseconds
  if len(a:timestamp) == 13
    let l:timestamp = a:timestamp[:-4]
  " this timestamp in expressed in microseconds
  elseif len(a:timestamp) == 16
    let l:timestamp = a:timestamp[:-7]
  else
    let l:timestamp = a:timestamp
  endif
  return strftime('%Y-%m-%d %H:%M:%S%z', l:timestamp)

endfunction

" Redirect command output to a register for later processing.
" Ref: https://stackoverflow.com/q/2573021/6064933 and https://unix.stackexchange.com/q/8101/221410 .
function! utils#CaptureCommandOutput(command) abort
  let l:tmp = @m
  redir @m
  silent! execute a:command
  redir END

  "create a scratch buffer for dumping the text, ref: https://vi.stackexchange.com/a/11311/15292.
  tabnew | setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile

  let l:lines = split(@m, '\n')
  call nvim_buf_set_lines(0, 0, 0, 0, l:lines)

  let @m = l:tmp
endfunction

" Edit all files matching the given patterns.
function! utils#MultiEdit(patterns) abort
  for p in a:patterns
    for f in glob(p, 0, 1)
      execute 'edit ' . f
    endfor
  endfor
endfunction

function! utils#StripTrailingWhitespace()
    let save_cursor = getpos(".")
    %s/\s\+$//e
    call setpos(".", save_cursor)
endfunction

" Check the syntax group in the current cursor position, see
" https://stackoverflow.com/q/9464844/6064933 and
" https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
function! utils#SynGroup() abort
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" Check if a colorscheme exists in runtimepath.
" The following two functions are inspired by https://stackoverflow.com/a/5703164/6064933.
function! utils#HasColorscheme(name) abort
  let l:pat = printf('colors/%s.vim', a:name)
  return !empty(globpath(&runtimepath, l:pat))
endfunction


