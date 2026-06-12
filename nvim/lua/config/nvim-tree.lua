-- nvim-tree: tree-view companion to oil.nvim
-- oil  → edit/rename files (press -)
-- nvim-tree → browse subtrees; E expand-all, W collapse-all, g? for all keys
require("nvim-tree").setup {
  -- oil already sets loaded_netrw globals; let it stay in charge
  disable_netrw = false,
  hijack_netrw  = false,

  view = {
    width = 35,
    side  = "left",
  },

  renderer = {
    group_empty            = true,  -- collapse empty intermediate dirs (a/b/c/ → a/b/c)
    highlight_git          = true,
    highlight_opened_files = "name",
    indent_markers         = { enable = true },
    icons = {
      git_placement = "after",
      show = { git = true, file = true, folder = true, folder_arrow = true },
    },
  },

  filters = {
    dotfiles = false,  -- show dotfiles; toggle live with H
    custom = {
      "^\\.git$", "node_modules", "\\.cache",
      "builddir", "__pycache__", "\\.o$", "\\.so$",
    },
  },

  git = {
    enable = true,
    ignore = false,  -- show git-ignored files; toggle live with I
  },

  -- auto-scroll the tree to highlight the current file on BufEnter
  update_focused_file = { enable = true },

  actions = {
    open_file = {
      quit_on_open  = false,
      window_picker = { enable = true },
    },
    expand_all = {
      max_folder_discovery = 500,
      exclude = { ".git", "node_modules", "builddir" },
    },
  },
}
