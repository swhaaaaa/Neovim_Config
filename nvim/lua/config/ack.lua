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

-- Search word under cursor across the project (Ack! = no auto-jump)
map("n", "<leader>ak", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end
  vim.cmd("Ack! " .. vim.fn.shellescape(word))
end, { silent = true, desc = "Ack: search word under cursor" })

-- Search visual selection across the project
map("v", "<leader>ak", function()
  local saved = vim.fn.getreg("z")
  local saved_type = vim.fn.getregtype("z")
  vim.cmd([[noautocmd normal! "zy]])
  local sel = vim.fn.getreg("z"):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  vim.fn.setreg("z", saved, saved_type)
  if sel == "" then return end
  vim.cmd("Ack! " .. vim.fn.shellescape(sel))
end, { silent = true, desc = "Ack: search visual selection" })

-- Open empty Ack prompt with cursor between quotes — type pattern (spaces allowed)
-- Uses --fixed-strings by default: safe for C/C++ expressions like "func(a, b)"
map("n", "<leader>akk", ':Ack! ""<Left>', { desc = "Ack: open prompt (literal)" })

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
-- (nohlsearch alone does not clear ack.vim's Search highlights)
map("n", "<leader>akc", function()
  vim.cmd("nohlsearch")
  -- Clear all match highlights set by ack.vim in every window
  vim.cmd("call clearmatches()")
  vim.notify("Ack highlights cleared", vim.log.levels.INFO)
end, { silent = true, desc = "Ack: clear highlights" })
