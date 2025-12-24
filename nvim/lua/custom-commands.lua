local api, cmd, fn = vim.api, vim.cmd, vim.fn

-- Extract ONLY hex bytes from canonical xxd line:
-- "00000010: ff ff ...  ASCII" -> "ffffffff..."
local function parse_hex_bytes_from_xxd_line(line)
  -- Skip empty lines
  if line == "" then return "" end

  -- xxd -g 1 -c 16 format: "XXXXXXXX: HH HH HH HH HH HH HH HH HH HH HH HH HH HH HH HH  ASCII"
  -- Example: "00000000: f0 18 87 8c cb 7d 49 43 98 00 a0 2f 05 9a ca 02  .....}IC.../...."
  -- Positions: 1-8 (offset), 9 (:), 10 (space), 11-57 (hex with spaces), 58-59 (two spaces), 60-75 (ASCII)

  if not line:match("^%x%x%x%x%x%x%x%x:") then return "" end

  -- Extract hex section: substring from position 11 to 57 (1-indexed in Lua)
  local hex_section
  if #line >= 57 then
    hex_section = line:sub(11, 57)
  elseif #line >= 11 then
    -- Last line might be shorter (less than 16 bytes)
    hex_section = line:sub(11)
  else
    return ""
  end

  -- Remove all spaces to get continuous hex
  local hex_only = hex_section:gsub("%s+", "")

  -- Validate: must be hex digits only
  if hex_only == "" or not hex_only:match("^[0-9a-fA-F]+$") then return "" end

  -- Validate: must be even length (complete bytes)
  if (#hex_only % 2) ~= 0 then return "" end

  return hex_only
end

local function canonical_buffer_to_plain_hex(buf)
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local out = {}
  local failed_lines = 0

  -- Sample first line for debugging
  if #lines > 0 then
    local sample = lines[1]
    vim.notify(string.format("Sample line (len=%d): [%s]", #sample, sample), vim.log.levels.INFO)
  end

  for i, l in ipairs(lines) do
    local hex = parse_hex_bytes_from_xxd_line(l)
    if #hex > 0 then
      table.insert(out, hex)
    elseif l:match("^%x+:") then
      -- This is an xxd line but we failed to parse it
      failed_lines = failed_lines + 1
      if failed_lines <= 3 then
        -- Only show first 3 failures to avoid spam
        vim.notify(string.format("Warning: Failed to parse line %d (len=%d): [%s]",
          i, #l, l), vim.log.levels.WARN)
      end
    end
  end

  local total_hex = table.concat(out, "")
  vim.notify(string.format("Parsed %d lines → %d bytes (%d failed)",
    #out, #total_hex / 2, failed_lines),
    failed_lines > 0 and vim.log.levels.ERROR or vim.log.levels.INFO)

  return total_hex
end

-- Replace buffer with raw bytes decoded from plain hex string (NO newline -> no 0x0a)
local function replace_with_raw_from_plain_hex(hexstr)
  hexstr = hexstr:gsub("%s+", "")
  if (#hexstr % 2) ~= 0 then
    vim.notify("Odd number of hex digits (missing half-byte).", vim.log.levels.ERROR)
    return false
  end

  -- For large files, write hex to temp file to avoid "argument list too long"
  local tmpfile = fn.tempname()
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Failed to create temp file for hex data", vim.log.levels.ERROR)
    return false
  end
  f:write(hexstr)
  f:close()

  -- Verify temp file was written correctly
  local tmp_size = fn.getfsize(tmpfile)
  vim.notify(string.format("Temp hex file: %d chars → %d bytes expected", #hexstr, #hexstr / 2), vim.log.levels.INFO)

  -- Decode from temp file - use explicit error capture
  local sh = string.format([[xxd -r -p < %s 2>&1]], fn.shellescape(tmpfile))
  local output = fn.system(sh)

  -- Check if xxd failed
  if vim.v.shell_error ~= 0 then
    vim.notify(string.format("xxd decode failed: %s", output), vim.log.levels.ERROR)
    fn.delete(tmpfile)
    return false
  end

  -- Replace buffer content with decoded binary
  -- Delete all lines first, then write the decoded output
  cmd("silent %delete _")

  -- Write decoded binary to buffer using system command
  sh = string.format([[xxd -r -p < %s]], fn.shellescape(tmpfile))
  local ok, err = pcall(function()
    cmd("silent 0read !" .. sh)
    -- Delete the empty first line that 'read' creates
    cmd("silent 1delete _")
  end)

  -- Clean up temp file
  fn.delete(tmpfile)

  if not ok then
    vim.notify(string.format("Failed to load decoded data: %s", err), vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Canonical view rendered from file on disk (prevents fake trailing 0x0a)
local function show_canonical_from_file()
  local path = fn.expand("%:p")
  if path ~= "" and fn.filereadable(path) == 1 then
    cmd(string.format("%%!xxd -g 1 -c 16 %s", fn.fnameescape(path)))
  else
    vim.notify("Buffer has no readable file on disk; save once for perfect HexOn view.", vim.log.levels.WARN)
    cmd([[%!xxd -g 1 -c 16]])
  end
  vim.bo.filetype = "xxd"
  vim.bo.readonly = false
  vim.bo.modifiable = true
  vim.bo.buftype = "nowrite"  -- lock normal :w in hex view
  vim.bo.binary = true         -- prevent EOL conversions
  vim.bo.eol = false           -- no end-of-line at EOF
  vim.bo.fixeol = false        -- don't fix missing EOL
  vim.b._hex_mode = true
end

local function leave_hex_mode()
  vim.bo.filetype = ""
  vim.bo.buftype  = ""
  vim.bo.readonly = false
  vim.bo.modifiable = true
  vim.b._hex_mode = nil
end

local function _hex_warn()
  vim.notify("Hex view is write-locked. Use :HexWrite (safe) or :HexOff then :w", vim.log.levels.WARN)
end

api.nvim_create_user_command("HexOn", function()
  show_canonical_from_file()
  vim.keymap.set("n", "ZZ", _hex_warn, { buffer = true, silent = true })
  vim.keymap.set("n", "<leader>w", _hex_warn, { buffer = true, silent = true, desc = "HexOn is locked" })

  -- Fixed: Create buffer-local command abbreviations that call the warning function
  cmd([[
    cnoreabbrev <buffer> <expr> w getcmdtype()==':' && getcmdline()=='w' && &l:filetype=='xxd' ? 'HexWarn' : 'w'
    cnoreabbrev <buffer> <expr> x getcmdtype()==':' && getcmdline()=='x' && &l:filetype=='xxd' ? 'HexWarn' : 'x'
  ]])

  -- Create a temporary command for the warning
  if not vim.g._hex_warn_cmd_created then
    api.nvim_create_user_command("HexWarn", _hex_warn, {})
    vim.g._hex_warn_cmd_created = true
  end
end, {})

api.nvim_create_user_command("HexOff", function()
  local buf = api.nvim_get_current_buf()
  if vim.bo.filetype == "xxd" then
    local hexstr = canonical_buffer_to_plain_hex(buf)
    if not replace_with_raw_from_plain_hex(hexstr) then return end
  end
  pcall(vim.keymap.del, "n", "ZZ",        { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>w", { buffer = true })
  cmd([[silent! unabbreviate <buffer> w | silent! unabbreviate <buffer> x]])
  leave_hex_mode()
end, {})

api.nvim_create_user_command("HexWrite", function()
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local buf = api.nvim_get_current_buf()
  local path = fn.expand("%:p")

  if path == "" then
    vim.notify("No file path - save the file first", vim.log.levels.ERROR)
    return
  end

  -- Check original file size
  local original_size = fn.getfsize(path)

  -- Extract and validate hex data
  local hexstr = canonical_buffer_to_plain_hex(buf)
  local new_size = #hexstr / 2

  -- Check if size changed
  if new_size ~= original_size then
    local diff = new_size - original_size
    local msg = string.format(
      "File size will change: %d → %d bytes (%s%d bytes)\nContinue? (y/N): ",
      original_size, new_size, diff > 0 and "+" or "", diff
    )
    local response = vim.fn.input(msg)
    if response:lower() ~= "y" then
      vim.notify("Write cancelled", vim.log.levels.WARN)
      return
    end
  end

  vim.notify(string.format("Writing %d bytes to file...", new_size), vim.log.levels.INFO)

  -- Write hex to temp file, then decode directly to target file
  local hex_tmpfile = fn.tempname()

  local f = io.open(hex_tmpfile, "w")
  if not f then
    vim.notify("Failed to create temp hex file", vim.log.levels.ERROR)
    return
  end
  f:write(hexstr)
  f:close()

  -- Decode directly to the target file (bypassing buffer completely)
  local decode_cmd = string.format("xxd -r -p < %s > %s",
    fn.shellescape(hex_tmpfile), fn.shellescape(path))
  local result = vim.fn.system(decode_cmd)

  fn.delete(hex_tmpfile)

  if vim.v.shell_error ~= 0 then
    vim.notify(string.format("Write failed: %s", result), vim.log.levels.ERROR)
    return
  end

  -- Verify the written file size
  local written_size = fn.getfsize(path)

  if written_size == new_size then
    vim.notify(string.format("Binary written successfully: %d bytes", written_size), vim.log.levels.INFO)
  else
    vim.notify(string.format("WARNING: Size mismatch! Expected %d, got %d", new_size, written_size),
      vim.log.levels.ERROR)
  end

  -- Re-render canonical view from the file on disk
  show_canonical_from_file()
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
