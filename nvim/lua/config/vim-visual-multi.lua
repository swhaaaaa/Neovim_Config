-- vim-visual-multi: multiple cursors
-- Must be set in init (before plugin loads), not config.
--
-- Core workflow:
--   <C-n>       select word under cursor; repeat to add next match
--   <C-n>       (visual) start multicursor on selection, then <C-n> adds next match
--   \\A         select ALL occurrences of word under cursor at once
--   \\/         start regex search to place cursors
--   \\\\        add cursor at current position
--
-- While in multicursor mode:
--   q           skip current match / move to next
--   Q           remove current cursor
--   <Tab>       switch between cursor mode and extend (visual) mode
--   n / N       find next/prev match
--   Normal vim commands (c, d, i, s, r, etc.) apply to all cursors simultaneously
--   <Esc>       exit multicursor mode

vim.g.VM_leader = "\\"

-- <C-Down> and <C-Up> are used for window resize in mappings.lua — disable them here.
vim.g.VM_maps = {
  ["Add Cursor Down"] = "",
  ["Add Cursor Up"]   = "",
}
