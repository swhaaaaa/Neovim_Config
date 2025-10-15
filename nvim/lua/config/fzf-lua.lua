-- lua/config/fzf-lua.lua
local ok, fzf = pcall(require, "fzf-lua")
if not ok then
  return
end

fzf.setup({
  defaults = {
    file_icons = "mini",
  },
  winopts = {
    -- NOTE: do not set "hl" here; it's deprecated upstream
    row = 0.5,
    height = 0.7,
  },
  files = {
    previewer = false,
  },
})

-- Normal-mode mappings
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>",     { desc = "Fuzzy find files", silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep (ripgrep)", silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>",  { desc = "Help tags", silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<cr>",     { desc = "Buffer tags", silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>",   { desc = "Open buffers", silent = true })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>",  { desc = "Recent files", silent = true })

vim.keymap.set('t', '<C-r>+', function()
  return vim.fn.getreg('+')
end, { expr = true, desc = 'Paste + into terminal/fzf' })

-- -------- Visual selection → live_grep (no resume) --------
-- Read the current visual selection *inclusively* and safely for all v-modes.
local function get_visual_text_inclusive(vmode)
  local bufnr = 0
  -- marks: (row 1-based, col 0-based)
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
  if srow == 0 or erow == 0 then return "" end

  -- normalize order
  if (erow < srow) or (erow == srow and ecol < scol) then
    srow, erow, scol, ecol = erow, srow, ecol, scol
  end

  local start_col = scol
  local end_col
  if vmode == "V" then
    -- linewise: start at col 0, go to end-of-line using INTEGER sentinel
    start_col = 0
    end_col = -1           -- IMPORTANT: must be an integer, -1 means "to EOL"
  else
    -- char/block-wise: end_col is exclusive in this API, include last char
    end_col = ecol + 1
  end

  local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, start_col, erow - 1, end_col, {})
  local s = table.concat(lines, " ")
  -- collapse whitespace and trim
  return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Visual-mode <leader>fg → seed live_grep with the selection (no resume)
vim.keymap.set("x", "<leader>fg", function()
  local vmode = vim.fn.visualmode()  -- "v", "V", or "\022" (CTRL-V)
  -- leave visual so marks get finalized, then run next tick
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    local query = get_visual_text_inclusive(vmode)
    if query ~= "" then
      fzf.live_grep({ search = query, resume = false })
    else
      fzf.live_grep({ resume = false })
    end
  end)
end, { desc = "Fuzzy grep selection", silent = true })
