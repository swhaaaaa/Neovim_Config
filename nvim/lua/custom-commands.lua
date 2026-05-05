local api, cmd, fn = vim.api, vim.cmd, vim.fn

-- Return to last cursor position when reopening a file
api.nvim_create_autocmd("BufReadPost", {
  group = api.nvim_create_augroup("LastPlace", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local bt  = vim.bo[buf].buftype
    local ft  = vim.bo[buf].filetype

    -- skip special buffers/filetypes
    if bt == "quickfix" or bt == "nofile" or bt == "help" or bt == "terminal" or bt == "prompt" then
      return
    end
    if ft == "gitcommit" or ft == "gitrebase" or ft == "svn" or ft == "hgcommit" then
      return
    end
    if vim.wo.previewwindow then
      return
    end

    -- get last position (" mark)
    local mark = api.nvim_buf_get_mark(buf, '"')
    local lnum, col = mark[1], mark[2]
    local last = api.nvim_buf_line_count(buf)

    if lnum > 0 and lnum <= last then
      pcall(api.nvim_win_set_cursor, 0, { lnum, math.max(col, 0) })
      vim.cmd("silent! normal! zv")  -- open folds around cursor
      vim.cmd("silent! normal! zz")  -- center screen (optional)
    end
  end,
})
