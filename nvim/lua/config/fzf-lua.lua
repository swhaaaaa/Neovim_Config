require("fzf-lua").setup {
  defaults = {
    file_icons = "mini",
  },
  winopts = {
    row = 0.5,
    height = 0.7,
  },
  files = {
    previewer = false,
  },
}

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Fuzzy grep tags in help files" })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<cr>", { desc = "Fuzzy search buffer tags" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy search opened buffers" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy search opened files history" })

-- Read the *current* visual selection correctly (inclusive)
local function get_visual_text_inclusive(vmode)
  local bufnr = 0
  -- nvim_buf_get_mark returns: (row 1-based, col 0-based)
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
  if srow == 0 or erow == 0 then return "" end

  -- normalize order
  if (erow < srow) or (erow == srow and ecol < scol) then
    srow, erow, scol, ecol = erow, srow, ecol, scol
  end

  -- START col is already 0-based → do NOT subtract 1
  local start_col = scol
  local end_col
  if vmode == "V" then
    start_col = 0
    end_col = math.huge       -- to end of line
  else
    -- char/block-wise: end col is EXCLUSIVE → +1 to include last char
    end_col = ecol + 1
  end

  local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, start_col, erow - 1, end_col, {})
  local s = table.concat(lines, " ")
  return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Visual-mode <leader>fg → live_grep seeded with selection (no resume)
vim.keymap.set("x", "<leader>fg", function()
  local vmode = vim.fn.visualmode()  -- "v", "V", or "\022"
  -- exit visual so marks finalize, then run next tick
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    local ok, fzf = pcall(require, "fzf-lua")
    if not ok then return end
    local q = get_visual_text_inclusive(vmode)
    if q ~= "" then
      fzf.live_grep({ search = q, resume = false })
    else
      fzf.live_grep({ resume = false })
    end
  end)
end, { desc = "Fuzzy grep selection", silent = true })
