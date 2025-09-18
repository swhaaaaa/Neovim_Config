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

