-- NORMAL mode
-- `gcc` - Toggles the current line using linewise comment
-- `gbc` - Toggles the current line using blockwise comment
-- `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
-- `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
-- `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
-- `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment

-- VISUAL mode
-- `gc` - Toggles the region using linewise comment
-- `gb` - Toggles the region using blockwise comment

local ok, comment = pcall(require, "Comment")
if not ok then return end

comment.setup({
  padding = true,           -- space between comment and text
  sticky  = true,           -- keep cursor position
  ignore  = "^$",           -- ignore empty lines
  mappings = { basic = true, extra = true }, -- gcc/gc + gco/gcO/gcA
})

