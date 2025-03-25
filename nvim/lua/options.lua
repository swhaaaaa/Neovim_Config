local opt = vim.opt
local o = vim.o
local g = vim.g
local fn = vim.fn

-- change fillchars for folding, vertical split, end of buffer, and message separator
vim.opt.fillchars = {
    fold = " ",
    foldsep = " ",
    foldopen = "",
    foldclose = "",
    vert = "│",
    eob = " ",
    msgsep = "‾",
    diff = "╱",
}

-- Split window below/right when creating horizontal/vertical windows
-- highlight cursor line underneath the cursor horizontally
opt.cursorline = true
-- open new vertical split bottom
opt.splitbelow = true

-- avoid the flickering when splitting window horizontal
vim.opt.splitkeep = "screen"

-- Time in milliseconds to wait for a mapped sequence to complete,
-- see https://unix.stackexchange.com/q/36882/221410 for more info
opt.timeoutlen = 500

-- For CursorHold events
opt.updatetime = 500

-- Clipboard settings, always use clipboard for all delete, yank, change, put
-- operation, see https://stackoverflow.com/q/30691466/6064933
if fn.empty(vim.fn["provider#clipboard#Executable"]()) == 0 then
    opt.clipboard:append("unnamedplus")
end

-- Disable creating swapfiles, see https://stackoverflow.com/q/821902/6064933
opt.swapfile = false

-- Ignore certain files and folders when globing
opt.wildignore:append({
    "*.o", "*.obj", "*.dylib", "*.bin", "*.dll", "*.exe",
    "*/.git/*", "*/.svn/*", "*/__pycache__/*", "*/build/**",
    "*.jpg", "*.png", "*.jpeg", "*.bmp", "*.gif", "*.tiff", "*.svg", "*.ico",
    "*.pyc", "*.pkl",
    "*.DS_Store",
    "*.aux", "*.bbl", "*.blg", "*.brf", "*.fls", "*.fdb_latexmk", "*.synctex.gz", "*.xdv"
})

-- ignore file and dir name cases in cmd-completion
opt.wildignorecase = true

-- Set up backup directory
local backup_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/backup//")
g.backupdir = backup_dir
opt.backupdir = backup_dir

-- Skip backup for patterns in option wildignore
opt.backupskip = vim.opt.wildignore:get()
opt.backup = true
opt.backupcopy = "yes"

-- General tab settings
opt.tabstop = 2 -- number of visual spaces per TAB
opt.softtabstop = 2 -- number of spacesin tab when editing
opt.shiftwidth = 2 -- insert 4 spaces on a tab
--opt.expandtab = true -- tabs are spaces, mainly because of python

-- Set matching pairs of characters and highlight matching brackets
opt.matchpairs:append({ "<:>", "「:」", "『:』", "【:】", "“:”", "‘:’", "《:》" })

-- Show line number and relative line number
opt.number = true -- show absolute number
opt.relativenumber = true -- add numbers to each line on the left side

-- Ignore case in general, but become case-sensitive when uppercase is present
opt.ignorecase = true -- ignore case in searches by default
opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- File and script encoding settings for vim
opt.fileencoding = "utf-8"
opt.fileencodings = { "ucs-bom", "utf-8", "cp936", "gb18030", "big5", "euc-jp", "euc-kr", "latin1" }

-- Break line at predefined characters
opt.linebreak = true
-- Character to show before the lines that have been soft-wrapped
opt.showbreak = "↪"

-- List all matches and complete till longest common string
opt.wildmode = { "list", "longest" }

-- Minimum lines to keep above and below cursor when scrolling
opt.scrolloff = 10

-- Use mouse to select and resize windows, etc.
opt.mouse = "a" -- allow the mouse to be used in Nvim
opt.mousemodel = "popup"  -- Set the behaviour of mouse
opt.mousescroll = { "ver:1", "hor:0" }

-- Disable showing current mode on command line since statusline plugins can show it.
opt.showmode = false

-- Fileformats to use for new files
opt.fileformats = { "unix", "dos" }

-- Ask for confirmation when handling unsaved or read-only files
opt.confirm = true

-- Do not use visual and errorbells
opt.visualbell = true
opt.errorbells = false

-- The number of command and search history to keep
opt.history = 500

-- Use list mode and customized listchars
opt.list = true
opt.listchars = {
    tab = "▸ ",
    extends = "❯",
    precedes = "❮",
    nbsp = "␣",
}

-- Auto-write the file based on some condition
opt.autowrite = true

-- Show hostname, full path of file and last-mod time on the window title. The
-- meaning of the format str for strftime can be found in
-- http://man7.org/linux/man-pages/man3/strftime.3.html. The function to get
-- lastmod time is drawn from https://stackoverflow.com/q/8426736/6064933
opt.title = true
opt.titlestring = ""
opt.titlestring = vim.fn["utils#Get_titlestr"]()

-- Persistent undo even after you close a file and re-open it
opt.undofile = true

-- c → Avoids showing completion messages (like "match 1 of 4").
-- Do not show "match xx of xx" and other messages during auto-completion

-- s → Prevents "search hit BOTTOM, continuing at TOP" messages.

-- I → Disables the startup message when opening Neovim.
-- Disable showing intro message (:intro)

-- S → Skips showing "search hit TOP" messages.
-- Do not show search match count on bottom right (seriously, I would strain my
-- neck looking at it). Using plugins like vim-anzu or nvim-hlslens is a better
-- choice, IMHO.
opt.shortmess:append("csIS")

-- Completion behaviour
-- Show menu even if there is only one item
opt.completeopt = { "menu", "menuone", "noselect" }
-- Disable the preview window
opt.completeopt:remove("preview")

-- Maximum number of items to show in popup menu
opt.pumheight = 10

-- pseudo transparency for completion menu
opt.pumblend = 5

-- pseudo transparency for floating window
opt.winblend = 0

-- Insert mode key word completion setting
vim.opt.complete:append("kspell")  -- Use spell-checking for completion
vim.opt.complete:remove("w")       -- Remove scanning buffers' words
vim.opt.complete:remove("b")       -- Remove scanning loaded buffers
vim.opt.complete:remove("u")       -- Remove scanning unloaded buffers
vim.opt.complete:remove("t")       -- Remove scanning tags

-- Spell languages
vim.opt.spelllang = { "en", "cjk" } -- Set spell-check languages to English and CJK (Chinese, Japanese, Korean)

-- show 9 spell suggestions at most
vim.opt.spellsuggest:append("9")    -- Limit spell suggestions to 9 options

-- Align indent to next multiple value of shiftwidth. For its meaning,
-- see http://vim.1045645.n5.nabble.com/shiftround-option-td5712100.html
opt.shiftround = true            -- Round indent to nearest multiple of 'shiftwidth'

-- Virtual edit is useful for visual block edit
opt.virtualedit = "block"        -- Allow virtual editing in block selection mode

-- Correctly break multi-byte characters such as CJK,
-- see https://stackoverflow.com/q/32669814/6064933
opt.formatoptions:append("mM")   -- Adjust formatting options

-- Tilde (~) is an operator, thus must be followed by motions like `e` or `w`.
opt.tildeop = true               -- Use `~` as an operator

-- Text after this column number is not highlighted
opt.synmaxcol = 250              -- Limit syntax highlighting to 250 columns
opt.startofline = false          -- Do not move cursor to start of line when moving vertically

-- External program to use for grep command
if fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    opt.grepformat = "%f:%l:%c:%m"
end

-- Enable true color support. Do not set this option if your terminal does not
-- support true colors! For a comprehensive list of terminals supporting true
-- colors, see https://github.com/termstandard/colors and https://gist.github.com/XVilka/8346728.
opt.termguicolors = true

-- Set up cursor color and shape in various mode, ref:
-- https://github.com/neovim/neovim/wiki/FAQ#how-to-change-cursor-color-in-the-terminal
opt.guicursor = {
    "n-v-c:block-Cursor/lCursor",
    "i-ci-ve:ver25-Cursor2/lCursor2",
    "r-cr:hor20",
    "o:hor20"
}

opt.signcolumn = "yes:1"

-- Remove certain character from file name pattern matching
opt.isfname:remove("=")
opt.isfname:remove("==")

-- Configure diff options
opt.diffopt = {
    "vertical",
    "filler",
    "closeoff",
    "context:3",
    "internal",
    "indent-heuristic",
    "algorithm:histogram",
    "linematch:60",
}

-- UI config
opt.wrap = false         -- Do not wrap lines
opt.ruler = false        -- Hide the ruler (line and column position)
opt.showcmdloc = "statusline" -- Show command location in the statusline

opt.splitright = true -- open new horizontal splits right
opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint
opt.laststatus = 3

-- Searching
opt.incsearch = true -- search as characters are entered
--opt.hlsearch = false -- do not highlight matches
opt.hlsearch = true -- highlight matches

-- interval for writing swap file to disk, also used by gitsigns
o.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
--opt.whichwrap:append "<>[]hl"

