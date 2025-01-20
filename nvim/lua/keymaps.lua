local map = vim.keymap.set
local o = vim.o
local g = vim.g

-- define common options
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

vim.g.mapleader = ','

-----------------
-- Normal mode --
-----------------

-- Moving around, tabs, windows and buffers
-- Treat long lines as break lines (useful when moving around in them)
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- Hint: see `:h vim.map.set()`
-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts, { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", opts, { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", opts, { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", opts, { desc = "switch window up" })

-- Resize with arrows
-- delta: 2 lines
map("n", "<C-Up>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- for nvim-tree
-- default leader key: ','
map("n", "<leader>nn", "<cmd>NvimTreeToggle<CR>", opts)
map("n", "<leader>nf", "<cmd>NvimTreeFindFile<CR>", opts)
map("n", "<leader>nr", "<cmd>NvimTreeRefresh<CR>", opts)

-- Disable highlight when <leader><cr> is pressed
map("n", "<leader><CR>", "<cmd>noh<CR>", opts, { desc = "general clear highlights" })

-- Fast saving
map("n", "<leader>w", "<cmd>w!<CR>", opts, { desc = "Fast saving" })
map("n", "<leader>wa", "<cmd>wall<CR>", opts, { desc = "Fast saving all" })

map("n", "<C-s>", "<cmd>w<CR>", opts, { desc = "file save" })
map("n", "<C-c>", "<cmd>%y+<CR>", opts, { desc = "file copy whole" })

-- Fast quiting
map("n", "<leader>qw", "<cmd>wq<CR>", opts)
map("n", "<leader>qf", "<cmd>q!<CR>", opts)
map("n", "<leader>qq", "<cmd>q<CR>", opts)
map("n", "<leader>qa", "<cmd>qa<CR>", opts)


map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "format files" })

-- tabufline
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })


-- Close the current buffer
map("n", "<leader>bd", "<cmd>bd!<CR>", { desc = "Close the current buffer" })

-- Close all the buffers
map("n", "<leader>ba", "<cmd>bufdo bd<CR>", { desc = "Close all the buffers" })

-- Useful mappings for managing tabs
map("n", "<leader>tn", "<cmd>tabnew<CR>")
--map("n", "<leader>to", "<cmd>tabonly<CR>")
map("n", "<leader>tc", "<cmd>tabclose<CR>")
map("n", "<leader>tm", "<cmd>tabmove<CR>")

-- next and prev tab
map("n", "<F7>", "<cmd>tabNext<CR>")
map("n", "<F8>", "<cmd>tabnext<CR>")
map("n", "<F6>", "<cmd>tabclose<CR>")

-- Opens a new tab with the current buffer's path
-- Super useful when editing files in the same directory
--map("n", "<leader>te", "<cmd>tabedit <c-r>=expand(\"%:p:h\")<CR>")
map("n", "<leader>te", function () return ':tabedit ' ..  vim.fn.expand '%:p:h' .. '/' end, { expr = true })

-- Switch CWD to the directory of the open buffer
map("n", "<leader>cd", "<cmd>cd %:p:h<CR>:pwd<CR>")

-- 定义快捷键到行首和行尾
map("n", "<leader>b", "0")
map("n", "<leader>e", "$")

-- 设置快捷键将选中文本块复制至系统剪贴板
map("v", "<leader>y", "\"+y")
map("v", "<leader>Y", "\"+Y")
-- 设置快捷键将系统剪贴板内容粘贴至 nvim
map("n", "<leader>p", "\"+p")
map("n", "<leader>P", "\"+P")
-- Mapping jj to <Esc> in Insert Mode, return Normal mode
map("i", "jj", "<ESC>")

-- Mvoe a line of text using ALT+[jk] or Comamnd+[jk] on mac
map("n", "<M-j>", "mz:m+<cr>`z")
map("n", "<M-k>", "mz:m-2<cr>`z")
map("n", "<M-l>", "xp")
map("n", "<M-h>", "x2hp")
--nmap <M-j> mz:m+<cr>`z
--nmap <M-k> mz:m-2<cr>`z
--nmap <M-l> xp
--nmap <M-h> x2hp

-- You should disable the "Keyboard Shortcuts" setting of terminal
map("v", "<M-j>", ":m'>+<cr>`<my`>mzgv`yo`z")
map("v", "<M-k>", ":m'<-2<cr>`>my`<mzgv`yo`z")
map("v", "<M-l>", "xmzpmy`zlv`y")
map("v", "<M-h>", "x2hmzpv`zl")


-- Comment
map("n", "<leader>c ", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "comment toggle" })

map(
  "v",
  "<leader>c ",
  "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { desc = "comment toggle" }
)


-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-----------------
-- Insert mode --
-----------------

map("i", "<C-b>", "<ESC>^i", opts, { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", opts, { desc = "move end of line" })
map("i", "<C-h>", "<Left>", opts, { desc = "move left" })
map("i", "<C-l>", "<Right>", opts, { desc = "move right" })
map("i", "<C-j>", "<Down>", opts, { desc = "move down" })
map("i", "<C-k>", "<Up>", opts, { desc = "move up" })


-----------------
-- telescope --
-----------------
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
map("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- """"""""""""""""""""""""""""""
-- " => Ack
-- " 1. curl http://betterthangrep.com/ack-standalone > ~/bin/ack && chmod 0755
-- " 2. sudo apt-get install ack-grep 
-- """"""""""""""""""""""""""""""
g.ackprg="ack -H --nocolor --nogroup --column -i --follow"
map("n", "<leader>ak", ":Ack! <C-R>=expand(\"<cword>\")<CR>", opts)
map("v", "<leader>ak", "y:Ack! \"<C-R>0\"", opts)
map("n", "<leader>akk", ":Ack! \"\"<left>", opts)

-- """"""""""""""""""""""""""""""
-- " => Tagbar setting
-- """"""""""""""""""""""""""""""
g.tagbar_width = 30
g.tagbar_expand = 1
--g.tagbar_left = 1
--g.tagbar_autoshowtag = 1
--g.tagbar_ctags_bin = 'ctags'
g.tagbar_ctags_bin = 'ctags-exuberant'
map("n", "<leader>bb", ":TagbarToggle<CR>", opts)

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""                                                                          
-- " => Nerd Tree                                                                                                                           
-- " NERDTree Menu         type 'm'                                                                                                         
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""                                                                          
-- let NERDTreeIgnore=[]                                                                                                                   
-- g.NERDTreeIgnore=['\.ko$', '\.mod.c$', '\~$']                                                                                          
-- let NERDTreeIgnore=['\.o$', '\.ko$', '\.mod.c$', '\~$']                                                                                 
g.NERDTreeShowHidden=1                                                                                                                 
map("n", "<leader>nn", ":NERDTreeToggle<CR>", opts)
map("n", "<leader>nb", ":NERDTreeFromBookmark<CR>", opts)
map("n", "<leader>nf", ":NERDTreeFind<CR>", opts)
-- au VimEnter *  NERDTree   


