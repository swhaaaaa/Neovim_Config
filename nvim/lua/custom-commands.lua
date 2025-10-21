local api, cmd, fn = vim.api, vim.cmd, vim.fn

local function _hex_warn()
  vim.notify("HexOn is write-LOCKED. Run :HexOff, then :w", vim.log.levels.WARN)
end

-- Hex view ON: show xxd, block all writes
api.nvim_create_user_command("HexOn", function()
  cmd([[%!xxd]])
  vim.bo.filetype = "xxd"
  vim.bo.buftype  = "nowrite"   -- makes :w/:x/:wq fail
  vim.bo.readonly = true        -- visual cue
  vim.b._hex_mode = true

  -- stop quit-with-write
  vim.keymap.set("n", "ZZ", _hex_warn, { buffer = true, silent = true })
  vim.keymap.set("n", "<leader>w", _hex_warn, { buffer = true, silent = true, desc = "HexOn is locked" })

  -- optional: redirect :w / :x to a friendly warning while in HexOn
  cmd([[
    cnoreabbrev <expr> w  getcmdtype()==':' && &l:filetype=='xxd' ? 'lua vim.notify("HexOn is write-LOCKED. :HexOff first.", vim.log.levels.WARN)' : 'w'
    cnoreabbrev <expr> x  getcmdtype()==':' && &l:filetype=='xxd' ? 'lua vim.notify("HexOn is write-LOCKED. :HexOff first.", vim.log.levels.WARN)' : 'x'
  ]])
end, {})

-- Hex view OFF: restore raw bytes, re-enable writes
api.nvim_create_user_command("HexOff", function()
  if vim.bo.filetype == "xxd" then
    cmd([[%!xxd -r]])
  end
  vim.bo.filetype = ""
  vim.bo.buftype  = ""
  vim.bo.readonly = false
  vim.b._hex_mode = nil

  pcall(vim.keymap.del, "n", "ZZ",        { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>w", { buffer = true })

  -- remove the temporary command-line abbreviations
  cmd([[
    cunabbrev w
    cunabbrev x
  ]])
end, {})

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
