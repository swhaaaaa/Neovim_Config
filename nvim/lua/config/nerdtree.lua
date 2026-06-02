-- nerdtree.lua — NERDTree file explorer configuration
-- NERDTree is a VimScript plugin — config uses vim.g variables

-- ── Appearance ────────────────────────────────────────────────────────────────
vim.g.NERDTreeShowHidden      = 1     -- show hidden files (dotfiles)
vim.g.NERDTreeMinimalUI       = 1     -- hide help text at top
vim.g.NERDTreeDirArrowExpandable  = ""  -- custom expand arrow
vim.g.NERDTreeDirArrowCollapsible = ""  -- custom collapse arrow
vim.g.NERDTreeWinSize         = 35    -- sidebar width
vim.g.NERDTreeStatusline      = ""    -- clean statusline in tree window
vim.g.NERDTreeAutoDeleteBuffer = 1    -- auto delete buffer of deleted file

-- ── Ignored files ─────────────────────────────────────────────────────────────
vim.g.NERDTreeIgnore = {
    "\\.git$",
    "node_modules$",
    "\\.cache$",
    "builddir$",
    "__pycache__$",
    "\\.o$",
    "\\.so$",
}

-- ── Keymaps ───────────────────────────────────────────────────────────────────
-- NOTE: keymaps are defined in plugin_specs.lua init() function
-- because NERDTree is lazy-loaded — init runs at startup, config runs after load

-- ── Wrap long filenames ───────────────────────────────────────────────────────
-- NERDTree forces nowrap; override it so long paths fold to the next line.
-- linebreak wraps at path separators rather than mid-filename.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "nerdtree",
    callback = function()
        vim.wo.wrap      = true
        vim.wo.linebreak = true
    end,
    desc = "Wrap long filenames in NERDTree",
})

-- ── Auto-close when NERDTree is last window ───────────────────────────────────
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("NERDTreeAutoClose", { clear = true }),
    callback = function()
        if vim.fn.tabpagenr("$") == 1
            and vim.fn.winnr("$") == 1
            and vim.bo.filetype == "nerdtree"
        then
            vim.cmd("quit")
        end
    end,
    desc = "Close Neovim when NERDTree is the only window",
})

-- ── Auto-refresh NERDTree ─────────────────────────────────────────────────────
-- Refresh tree when:
--   BufWritePost  — after saving a file
--   FocusGained   — when Neovim gains focus from OS
--   WinEnter      — when switching between Neovim windows/splits
vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("NERDTreeAutoRefresh", { clear = true }),
    callback = function()
        if vim.fn.exists("g:NERDTree") == 1
            and vim.fn.eval("g:NERDTree.IsOpen()") == 1
        then
            vim.cmd("NERDTreeRefreshRoot")
        end
    end,
    desc = "Auto-refresh NERDTree on file write, focus, or window switch",
})
