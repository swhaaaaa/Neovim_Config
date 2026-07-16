function! buf_utils#GoToBuffer(count, direction) abort
  if a:count == 0
    if a:direction ==# 'forward'
      bnext
    elseif a:direction ==# 'backward'
      bprevious
    else
      echoerr 'Bad argument: ' . a:direction
    endif
    return
  endif
  " Check the validity of buffer number.
  if index(s:GetBufNums(), a:count) == -1
    " Using `lua vim.notify('invalid bufnr: ' .. a:count)` won't work, because
    " we are essentially mixing Lua and vim script. We need to make sure that
    " args inside vim.notify() are valid vim values. The conversion from vim
    " value to lua value will be done by Nvim. See also https://github.com/neovim/neovim/pull/11338.
    call v:lua.vim.notify('Invalid bufnr: ' . a:count, 4, {'title': 'nvim-config'})
    return
  endif

  " Direction only matters for the count==0 case above; with an explicit
  " buffer number, jump straight to it regardless of gb/gB.
  silent execute('buffer' . a:count)
endfunction

function! s:GetBufNums() abort
  return map(copy(getbufinfo({'buflisted':1})), 'v:val.bufnr')
endfunction
