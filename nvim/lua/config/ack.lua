-- lua/config/ack.lua
-- ack.vim configuration — mirrors the vimrcs setup.
-- Uses ripgrep (rg) as the backend if available (faster, respects .gitignore),
-- otherwise falls back to ack, then ack-grep.

if vim.fn.executable("rg") == 1 then
  -- Use ripgrep as ack backend.
  -- --fixed-strings (-F): treat the pattern as a literal string, not regex.
  -- This matches ack's default behaviour and prevents errors when searching
  -- for C/C++ expressions like "cpha0(spi, n)" that contain regex metacharacters.
  vim.g.ackprg = "rg --vimgrep --no-heading --smart-case --follow --fixed-strings"
elseif vim.fn.executable("ack") == 1 then
  -- ack: case-insensitive, follow symlinks, show column numbers (from vimrcs)
  vim.g.ackprg = "ack -H --nocolor --nogroup --column -i --follow"
elseif vim.fn.executable("ack-grep") == 1 then
  -- Debian/Ubuntu older package name
  vim.g.ackprg = "ack-grep -H --nocolor --nogroup --column -i --follow"
end

-- Do NOT use ackhighlight — it applies the Search highlight group directly
-- to matches in every buffer, and :nohlsearch does not clear it.
-- ripgrep/fzf-lua handles highlighting better; keep ack results undecorated.
vim.g.ackhighlight = 0

-- ── Keymaps ────────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- Search word under cursor (mirrors: nmap <leader>ak :Ack! <C-R>=expand("<cword>")<CR>)
map("n", "<leader>ak",
  ':Ack! <C-R>=expand("<cword>")<CR>',
  { desc = "Ack: search word under cursor" })

-- Search visual selection — pre-fills command line so path/options can be appended
map("v", "<leader>ak",
  'y:Ack! "<C-R>0"',
  { desc = "Ack: search visual selection (pre-fill)" })

-- Open empty Ack prompt (mirrors: map <leader>akk :Ack! "" <left><left>)
map("n", "<leader>akk",
  ':Ack! "" <left><left>',
  { desc = "Ack: open prompt" })

-- :AckRegex {pattern}  — same as :Ack! but without --fixed-strings
-- Use when you actually need regex: :AckRegex cpha\d+
vim.api.nvim_create_user_command("AckRegex", function(opts)
  local saved = vim.g.ackprg
  vim.g.ackprg = saved:gsub(" %-%-fixed%-strings", "")
  vim.cmd("Ack! " .. opts.args)
  vim.g.ackprg = saved
end, { nargs = "+", desc = "Ack with regex (no --fixed-strings)" })

-- ,akr — open :AckRegex "" prompt for manual regex search
map("n", "<leader>akr", ':AckRegex ""<Left>', { desc = "Ack: open regex prompt" })

-- Clear any leftover Ack match highlights explicitly
map("n", "<leader>akc", function()
  vim.cmd("nohlsearch")
  vim.cmd("call clearmatches()")
  vim.notify("Ack highlights cleared", vim.log.levels.INFO)
end, { silent = true, desc = "Ack: clear highlights" })
