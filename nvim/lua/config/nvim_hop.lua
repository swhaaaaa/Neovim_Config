local keymap = vim.keymap
local ok, hop = pcall(require, "hop")
if not ok then return end
hop.setup {
  case_insensitive = true,
  char2_fallback_key = "<CR>",
  quit_key = "<Esc>",
  match_mappings = { "zh_sc" },
}

local dir = require("hop.hint").HintDirection

keymap.set({ "n", "v", "o" }, "f", function()
  hop.hint_char2({ direction = dir.AFTER_CURSOR })
end, { silent = true, noremap = true, desc = "hop: find forward (2-char)" })

keymap.set({ "n", "v", "o" }, "F", function()
  hop.hint_char2({ direction = dir.BEFORE_CURSOR })
end, { silent = true, noremap = true, desc = "hop: find backward (2-char)" })

keymap.set({ "n", "v", "o" }, "t", function()
  hop.hint_char2({ direction = dir.AFTER_CURSOR,  hint_offset = -1 })
end, { silent = true, noremap = true, desc = "hop: till forward (2-char)" })

keymap.set({ "n", "v", "o" }, "T", function()
  hop.hint_char2({ direction = dir.BEFORE_CURSOR, hint_offset = 1 })
end, { silent = true, noremap = true, desc = "hop: till backward (2-char)" })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd([[
      hi HopNextKey cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
      hi HopNextKey1 cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
      hi HopNextKey2 cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
    ]])
  end,
})
