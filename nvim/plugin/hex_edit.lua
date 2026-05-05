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
  -- Undo every flag that show_canonical_from_file() set
  vim.bo.filetype   = ""
  vim.bo.buftype    = ""       -- was "nowrite" — restores normal :w
  vim.bo.binary     = false    -- was true — re-enables EOL handling
  vim.bo.eol        = true     -- restore end-of-line
  vim.bo.fixeol     = true     -- restore fix-eol
  vim.bo.readonly   = false
  vim.bo.modifiable = true
  vim.b._hex_mode   = nil

  -- Mark buffer as unmodified BEFORE reloading. Without this Neovim sees
  -- the xxd text as unsaved changes and asks "Save changes to file?".
  -- The real data was already written to disk by HexWrite, so it is safe.
  vim.bo.modified = false

  -- :edit! reloads from disk unconditionally (no confirm dialog).
  pcall(cmd, "edit!")
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
  -- Remove buffer-local keymaps (pcall so a missing map won't abort)
  pcall(vim.keymap.del, "n", "ZZ",        { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>w", { buffer = true })

  -- `cunabbrev` removes cmdline abbreviations.
  -- NOTE: Neovim has no buffer-local cabbrev scope, so remove them globally.
  pcall(cmd, "cunabbrev w")
  pcall(cmd, "cunabbrev x")

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

-- Helper command: Insert bytes at current cursor position
api.nvim_create_user_command("HexInsert", function(opts)
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local args = opts.fargs

  -- Parse arguments: can be "4 aa" (repeat) or "aa bb cc dd" (sequence)
  local bytes_to_insert = {}

  if #args == 0 then
    -- Default: insert one 0x00 byte
    bytes_to_insert = {"00"}
  elseif #args == 1 then
    -- Single arg: could be count or single byte
    if args[1]:match("^%d+$") and tonumber(args[1]) > 16 then
      -- Large number: treat as count, use 00 as default
      local count = tonumber(args[1])
      for i = 1, count do
        table.insert(bytes_to_insert, "00")
      end
    else
      -- Otherwise treat as hex byte
      table.insert(bytes_to_insert, args[1])
    end
  elseif #args == 2 and args[1]:match("^%d+$") then
    -- Two args with first being a number: count + repeating byte
    local count = tonumber(args[1])
    local byte_value = args[2]
    if not byte_value:match("^[0-9a-fA-F][0-9a-fA-F]$") then
      vim.notify("Invalid byte value. Use 2 hex digits", vim.log.levels.ERROR)
      return
    end
    for i = 1, count do
      table.insert(bytes_to_insert, byte_value)
    end
  else
    -- Multiple args: treat as byte sequence
    for _, byte in ipairs(args) do
      if not byte:match("^[0-9a-fA-F][0-9a-fA-F]$") then
        vim.notify(string.format("Invalid byte '%s'. Use 2 hex digits each", byte), vim.log.levels.ERROR)
        return
      end
      table.insert(bytes_to_insert, byte)
    end
  end

  local cursor_line = vim.fn.line(".")
  local cursor_col = vim.fn.col(".")
  local current_line = vim.fn.getline(cursor_line)

  -- Parse current line
  local offset = tonumber(current_line:match("^(%x+):"), 16)
  if not offset then
    vim.notify("Could not parse offset", vim.log.levels.ERROR)
    return
  end

  -- Determine byte position in line based on cursor column
  local hex_start_col = 11
  if cursor_col < hex_start_col then cursor_col = hex_start_col end

  -- Calculate which byte position (0-15) the cursor is on
  local rel_col = cursor_col - hex_start_col
  local byte_pos = math.floor(rel_col / 3)
  byte_pos = math.max(0, math.min(15, byte_pos))

  local hex_section = parse_hex_bytes_from_xxd_line(current_line)

  -- Convert hex string to byte array
  local bytes = {}
  for i = 1, #hex_section, 2 do
    table.insert(bytes, hex_section:sub(i, i + 1))
  end

  -- Insert new bytes at position
  for i, byte_val in ipairs(bytes_to_insert) do
    table.insert(bytes, byte_pos + i, byte_val)
  end

  -- Rebuild lines (may need to split into multiple lines)
  local new_lines = {}
  local curr_offset = offset

  for i = 1, #bytes, 16 do
    local line_bytes = {}
    for j = i, math.min(i + 15, #bytes) do
      table.insert(line_bytes, bytes[j])
    end

    local hex_str = table.concat(line_bytes, " ")
    local ascii_str = string.rep(".", #line_bytes)
    local line = string.format("%08x: %-47s  %s", curr_offset, hex_str, ascii_str)

    table.insert(new_lines, line)
    curr_offset = curr_offset + #line_bytes
  end

  -- Replace current line and insert additional lines if needed
  vim.fn.setline(cursor_line, new_lines[1])
  if #new_lines > 1 then
    vim.fn.append(cursor_line, vim.list_slice(new_lines, 2))
  end

  local bytes_display = table.concat(bytes_to_insert, " ")
  vim.notify(string.format("Inserted %d byte(s) [%s] at offset 0x%x. Run :HexReoffset then :HexWrite.",
    #bytes_to_insert, bytes_display, offset + byte_pos), vim.log.levels.INFO)
end, { nargs = "*", desc = "Insert bytes at cursor: HexInsert aa bb cc OR HexInsert 4 aa" })

-- Helper command: Append bytes to the end
api.nvim_create_user_command("HexAppend", function(opts)
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local args = opts.fargs
  local bytes_to_append = {}

  if #args == 0 then
    -- Default: 16 bytes of 0x00
    for i = 1, 16 do
      table.insert(bytes_to_append, "00")
    end
  elseif #args == 1 then
    -- Could be count or single byte
    if args[1]:match("^%d+$") and tonumber(args[1]) > 16 then
      local count = tonumber(args[1])
      for i = 1, count do
        table.insert(bytes_to_append, "00")
      end
    else
      table.insert(bytes_to_append, args[1])
    end
  elseif #args == 2 and args[1]:match("^%d+$") then
    -- count + repeating byte
    local count = tonumber(args[1])
    local byte_value = args[2]
    if not byte_value:match("^[0-9a-fA-F][0-9a-fA-F]$") then
      vim.notify("Invalid byte value", vim.log.levels.ERROR)
      return
    end
    for i = 1, count do
      table.insert(bytes_to_append, byte_value)
    end
  else
    -- Byte sequence
    for _, byte in ipairs(args) do
      if not byte:match("^[0-9a-fA-F][0-9a-fA-F]$") then
        vim.notify(string.format("Invalid byte '%s'", byte), vim.log.levels.ERROR)
        return
      end
      table.insert(bytes_to_append, byte)
    end
  end

  local buf = api.nvim_get_current_buf()
  local last_line_num = api.nvim_buf_line_count(buf)
  local last_line = api.nvim_buf_get_lines(buf, last_line_num - 1, last_line_num, false)[1]

  -- Parse last offset
  local last_offset = tonumber(last_line:match("^(%x+):"), 16)
  if not last_offset then
    vim.notify("Could not parse last line offset", vim.log.levels.ERROR)
    return
  end

  -- Calculate how many bytes are on the last line
  local last_hex = parse_hex_bytes_from_xxd_line(last_line)
  local bytes_on_last_line = #last_hex / 2
  local next_offset = last_offset + bytes_on_last_line

  -- Generate new lines
  local new_lines = {}
  local byte_idx = 1

  while byte_idx <= #bytes_to_append do
    local bytes_this_line = math.min(#bytes_to_append - byte_idx + 1, 16)
    local line_bytes = {}

    for i = 1, bytes_this_line do
      table.insert(line_bytes, bytes_to_append[byte_idx])
      byte_idx = byte_idx + 1
    end

    local hex_str = table.concat(line_bytes, " ")
    local ascii_str = string.rep(".", #line_bytes)
    local line = string.format("%08x: %-47s  %s", next_offset, hex_str, ascii_str)

    table.insert(new_lines, line)
    next_offset = next_offset + bytes_this_line
  end

  -- Append lines to buffer
  api.nvim_buf_set_lines(buf, last_line_num, last_line_num, false, new_lines)

  local bytes_display = table.concat(bytes_to_append, " ")
  vim.notify(string.format("Appended %d byte(s) [%s]. Use :HexWrite to save.",
    #bytes_to_append, #bytes_to_append <= 8 and bytes_display or (bytes_display:sub(1, 23) .. "...")),
    vim.log.levels.INFO)
end, { nargs = "*", desc = "Append bytes: HexAppend aa bb cc OR HexAppend 32 ff" })

-- Helper command: Recalculate all offsets after insertions/deletions
api.nvim_create_user_command("HexReoffset", function()
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local new_lines = {}
  local current_offset = 0

  for i, line in ipairs(lines) do
    if line:match("^%x+:") then
      -- Extract hex bytes from this line
      local hex_bytes = parse_hex_bytes_from_xxd_line(line)

      if #hex_bytes > 0 then
        -- Rebuild line with correct offset
        local byte_count = #hex_bytes / 2
        local formatted_bytes = {}

        for j = 1, #hex_bytes, 2 do
          table.insert(formatted_bytes, hex_bytes:sub(j, j + 1))
        end

        local hex_str = table.concat(formatted_bytes, " ")
        local ascii_str = string.rep(".", byte_count)
        local new_line = string.format("%08x: %-47s  %s", current_offset, hex_str, ascii_str)

        table.insert(new_lines, new_line)
        current_offset = current_offset + byte_count
      end
    else
      -- Keep non-xxd lines as-is
      table.insert(new_lines, line)
    end
  end

  -- Replace all lines
  api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
  vim.notify(string.format("Reoffset complete. Total: %d bytes (0x%x)", current_offset, current_offset),
    vim.log.levels.INFO)
end, { desc = "Recalculate all line offsets after edits" })

-- Helper command: Delete N bytes at cursor position
api.nvim_create_user_command("HexDelete", function(opts)
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local count = tonumber(opts.args) or 1
  local cursor_line = vim.fn.line(".")
  local cursor_col = vim.fn.col(".")
  local current_line = vim.fn.getline(cursor_line)

  -- Parse current line
  local offset = tonumber(current_line:match("^(%x+):"), 16)
  if not offset then
    vim.notify("Could not parse offset", vim.log.levels.ERROR)
    return
  end

  -- Calculate byte position
  local hex_start_col = 11
  if cursor_col < hex_start_col then cursor_col = hex_start_col end
  local rel_col = cursor_col - hex_start_col
  local byte_pos = math.floor(rel_col / 3)
  byte_pos = math.max(0, math.min(15, byte_pos))

  -- Collect bytes from current line and following lines
  local buf = api.nvim_get_current_buf()
  local all_bytes = {}
  local lines_to_check = math.ceil(count / 16) + 5  -- Check extra lines

  for i = 0, lines_to_check do
    local line_num = cursor_line + i
    local line = vim.fn.getline(line_num)
    if line:match("^%x+:") then
      local hex = parse_hex_bytes_from_xxd_line(line)
      for j = 1, #hex, 2 do
        table.insert(all_bytes, hex:sub(j, j + 1))
      end
    end
  end

  -- Calculate absolute position and delete bytes
  local abs_pos = byte_pos + 1
  for i = 1, count do
    if abs_pos <= #all_bytes then
      table.remove(all_bytes, abs_pos)
    end
  end

  -- Rebuild lines
  local new_lines = {}
  local curr_offset = offset

  for i = 1, #all_bytes, 16 do
    local line_bytes = {}
    for j = i, math.min(i + 15, #all_bytes) do
      table.insert(line_bytes, all_bytes[j])
    end

    local hex_str = table.concat(line_bytes, " ")
    local ascii_str = string.rep(".", #line_bytes)
    local line = string.format("%08x: %-47s  %s", curr_offset, hex_str, ascii_str)

    table.insert(new_lines, line)
    curr_offset = curr_offset + #line_bytes
  end

  -- Replace lines
  local lines_to_replace = math.min(lines_to_check + 1, #new_lines)
  api.nvim_buf_set_lines(buf, cursor_line - 1, cursor_line - 1 + lines_to_replace, false, new_lines)

  -- Delete any extra old lines
  if lines_to_replace < lines_to_check + 1 then
    api.nvim_buf_set_lines(buf, cursor_line - 1 + #new_lines, cursor_line + lines_to_check, false, {})
  end

  vim.notify(string.format("Deleted %d byte(s) at offset 0x%x. Run :HexReoffset then :HexWrite.",
    count, offset + byte_pos), vim.log.levels.INFO)
end, { nargs = "?", desc = "Delete N bytes at cursor (HexDelete [count])" })

-- Helper command: Insert a full 16-byte line at cursor
api.nvim_create_user_command("HexInsertLine", function(opts)
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local byte_value = opts.args ~= "" and opts.args or "00"

  -- Validate byte value
  if not byte_value:match("^[0-9a-fA-F][0-9a-fA-F]$") then
    vim.notify("Invalid byte value. Use 2 hex digits (e.g., 00, ff, a5)", vim.log.levels.ERROR)
    return
  end

  local cursor_line = vim.fn.line(".")
  local current_line = vim.fn.getline(cursor_line)

  -- Parse current offset
  local offset = tonumber(current_line:match("^(%x+):"), 16)
  if not offset then
    vim.notify("Could not parse offset from current line", vim.log.levels.ERROR)
    return
  end

  -- Create a new line with 16 bytes
  local hex_bytes = {}
  for i = 1, 16 do
    table.insert(hex_bytes, byte_value)
  end

  local hex_str = table.concat(hex_bytes, " ")
  local ascii_str = string.rep(".", 16)
  local new_line = string.format("%08x: %-47s  %s", offset, hex_str, ascii_str)

  -- Insert below current line
  vim.fn.append(cursor_line, new_line)
  vim.notify("Inserted 16 bytes (0x" .. byte_value .. "). Run :HexReoffset then :HexWrite to save.",
    vim.log.levels.WARN)
end, { nargs = "?", desc = "Insert 16 bytes at cursor (HexInsertLine [byte_value])" })

-- Helper command: Delete N whole xxd lines at cursor (= N*16 bytes each)
-- Usage:  :HexDeleteLine        → delete 1 line (16 bytes)
--         :HexDeleteLine 3      → delete 3 lines (48 bytes)
-- After deleting, run :HexReoffset then :HexWrite to persist the change.
api.nvim_create_user_command("HexDeleteLine", function(opts)
  if vim.bo.filetype ~= "xxd" or not vim.b._hex_mode then
    vim.notify("Not in HexOn mode", vim.log.levels.WARN)
    return
  end

  local count = math.max(1, tonumber(opts.args) or 1)
  local buf   = api.nvim_get_current_buf()
  local total = api.nvim_buf_line_count(buf)
  local first = vim.fn.line(".") - 1   -- 0-indexed

  -- Clamp so we never delete past the last line
  local last = math.min(first + count, total)
  local actual = last - first

  -- Count bytes being removed (for the notify message)
  local removed_bytes = 0
  for i = first, last - 1 do
    local line = api.nvim_buf_get_lines(buf, i, i + 1, false)[1] or ""
    local hex  = parse_hex_bytes_from_xxd_line(line)
    removed_bytes = removed_bytes + (#hex / 2)
  end

  -- Get offset of the first deleted line for the message
  local first_line = api.nvim_buf_get_lines(buf, first, first + 1, false)[1] or ""
  local start_offset = tonumber(first_line:match("^(%x+):"), 16) or 0

  api.nvim_buf_set_lines(buf, first, last, false, {})

  vim.notify(string.format(
    "Deleted %d line(s) / %d byte(s) at offset 0x%08x. Run :HexReoffset then :HexWrite to save.",
    actual, removed_bytes, start_offset
  ), vim.log.levels.WARN)
end, { nargs = "?", desc = "Delete N xxd lines at cursor (HexDeleteLine [count])" })

