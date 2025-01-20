local opt = vim.opt
local o = vim.o
local g = vim.g

-- Hint: use `:h <option>` to figure out the meaning if needed
opt.clipboard = "unnamedplus" -- use system clipboard
opt.completeopt = { "menu", "menuone", "noselect" }
opt.mouse = "a" -- allow the mouse to be used in Nvim
opt.scrolloff = 10 -- no less than 10 lines even if you keep scrolling down

-- Tab
opt.tabstop = 4 -- number of visual spaces per TAB
opt.softtabstop = 4 -- number of spacesin tab when editing
opt.shiftwidth = 4 -- insert 4 spaces on a tab
opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
opt.number = true -- show absolute number
opt.relativenumber = true -- add numbers to each line on the left side
opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
opt.splitbelow = true -- open new vertical split bottom
opt.splitright = true -- open new horizontal splits right
opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint
opt.laststatus = 3

-- Searching
opt.incsearch = true -- search as characters are entered
--opt.hlsearch = false -- do not highlight matches
opt.hlsearch = true -- highlight matches
opt.ignorecase = true -- ignore case in searches by default
opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- disable nvim intro
opt.shortmess:append "sI"

-- interval for writing swap file to disk, also used by gitsigns
o.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
--opt.whichwrap:append "<>[]hl"



-- For nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1


