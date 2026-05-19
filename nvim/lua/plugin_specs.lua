local utils = require("utils")

local plugin_dir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = plugin_dir .. "/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local firenvim_not_active = function()
  return not vim.g.started_by_firenvim
end

local plugin_specs = {
  -- ─── Completion ──────────────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    name = "nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- LuaSnip as primary snippet engine (replaces UltiSnips for cmp)
      {
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          -- Load friendly-snippets (VSCode format)
          require("luasnip.loaders.from_vscode").lazy_load()
          -- NOTE: custom my_snippets/ use UltiSnips syntax — loaded by UltiSnips directly
        end,
      },
      -- Autopairs integrated with cmp confirm
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)
          local cmp_autopairs = require "nvim-autopairs.completion.cmp"
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },
      -- cmp sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-omni",
      "https://codeberg.org/FelipeLema/cmp-async-path.git",
      "saadparwaiz1/cmp_luasnip",
      "quangnguyen30192/cmp-nvim-ultisnips",  -- UltiSnips source for nvim-cmp
    },
    config = function()
      require("config.nvim-cmp")
    end,
  },

  -- UltiSnips kept for .snippets file format support
  {
    "SirVer/ultisnips",
    init = function()
      vim.g.UltiSnipsExpandTrigger = "<c-j>"
      vim.g.UltiSnipsEnableSnipMate = 0
      vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
      vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "my_snippets" }
    end,
    dependencies = { "honza/vim-snippets" },
    event = "InsertEnter",
  },

  -- ─── LSP ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.lsp")
    end,
  },

  -- clangd_extensions: enhances clangd with inlay hints, better AST view,
  -- and memory usage display. Useful for C/C++ kernel development.
  -- Inlay hints show parameter names and types inline, e.g.:
  --   spi_gpio_txrx_word_mode0(spi: *spi_device, nsecs: u32, ...)
  -- Toggle inlay hints: <leader>ih
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    config = function()
      require("config.clangd_extensions")
    end,
  },
  {
    "dnlhc/glance.nvim",
    event = "VeryLazy",
    config = function()
      require("config.glance")
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "BufRead",
    config = function()
      require("config.fidget-nvim")
    end,
  },
  {
    "kosayoda/nvim-lightbulb",
    event = "BufRead",
    config = function()
      require("config.lightbulb")
    end,
  },
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        c          = { "clang_format" },
        cpp        = { "clang_format" },
        lua        = { "stylua" },
        python     = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
      },
      format_on_save = false,
      -- clang_format reads .clang-format in project root automatically.
      -- For kernel work, create a .clang-format with:
      --   BasedOnStyle: Linux
      --   IndentWidth: 8
      --   UseTab: Always
    },
  },

  -- ─── Treesitter ───────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
  },

  -- nvim-treesitter-context: shows current function/struct/block at top of window
  -- while scrolling through long files. Max 3 lines to avoid taking too much space.
  -- Useful in kernel source where functions can be hundreds of lines long.
  -- Toggle with <leader>ux  |  Jump to context with [C
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      enable            = true,
      max_lines         = 3,   -- max lines the context window can take
      min_window_height = 20,  -- don't show in very short windows
      line_numbers      = true,
      multiline_threshold = 1, -- only show single-line context entries
      trim_scope        = "outer",
      mode              = "cursor",
      separator         = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      -- Note: <leader>tc is reserved for tabclose (mappings.lua)
      -- Using <leader>ux for treesitter context toggle
      vim.keymap.set("n", "<leader>ux", function()
        require("treesitter-context").toggle()
      end, { silent = true, desc = "toggle treesitter context" })
      -- Jump to context (e.g. jump to the function signature from inside its body)
      vim.keymap.set("n", "[C", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true, desc = "jump to context (treesitter)" })
    end,
  },
  -- nvim-treesitter-textobjects removed: its plugin/nvim-treesitter-textobjects.vim
  -- still requires nvim-treesitter.configs (old API) which no longer exists.
  -- Use mini.ai or native treesitter keymaps instead.

  -- mini.ai: better textobjects (replaces nvim-treesitter-textobjects)
  -- Adds: a/i + f(unction), c(lass), a(rgument), b(racket), q(uote), etc.
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup { n_lines = 500 }
    end,
  },

  -- mini.surround: add/delete/replace surrounding pairs
  -- sa{motion}{char} → add,  sd{char} → delete,  sr{old}{new} → replace
  -- Example: saiw"  wraps word in quotes;  sd"  removes quotes
  {
    "echasnovski/mini.surround",
    version = false,
    event = "VeryLazy",
    opts = {
      mappings = {
        add            = "sa",
        delete         = "sd",
        find           = "sf",
        find_left      = "sF",
        highlight      = "sh",
        replace        = "sr",
        update_n_lines = "sn",
      },
    },
  },

  -- ─── UI ───────────────────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.icons",
    version = false,
    lazy = true,
    config = function()
      require("mini.icons").mock_nvim_web_devicons()
      require("mini.icons").tweak_lsp_kind()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "BufRead",
    cond = firenvim_not_active,
    config = function()
      require("config.lualine")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "BufEnter",
    cond = firenvim_not_active,
    config = function()
      require("config.bufferline")
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
        highlight = "IblIndent",
      },
      scope = {
        enabled = true,
        char = "▏",
        highlight = "IblScope",
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "neo-tree", "Trouble",
          "lazy", "mason", "notify", "toggleterm",
        },
      },
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {},
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("config.bqf")
    end,
  },
  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    config = function()
      require("config.nvim-statuscol")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      require("config.nvim_ufo")
    end,
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("config.nvim-notify")
    end,
  },
  { "itchyny/vim-highlighturl", event = "BufReadPost" },

  -- ─── Colorschemes ─────────────────────────────────────────────────────────────
  -- All lazy-loaded; only the one set in colorschemes.lua is ever loaded at startup.
  -- Remove any you never use to keep :Lazy clean.
  { "sainnhe/everforest",       lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
  { "sainnhe/sonokai",          lazy = true },
  { "folke/tokyonight.nvim",    lazy = true },
  { "catppuccin/nvim",          name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim",    lazy = true },
  { "EdenEast/nightfox.nvim",   lazy = true },

  -- ─── Navigation ───────────────────────────────────────────────────────────────
  {
    "smoka7/hop.nvim",
    keys = { "f" },
    config = function()
      require("config.nvim_hop")
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    branch = "main",
    keys = { "*", "#", "n", "N" },
    config = function()
      require("config.hlslens")
    end,
  },
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    config = function()
      require("config.fzf-lua")
    end,
  },
  -- oil.nvim: edit filesystem like a buffer — complement to nvim-tree
  -- Press - to open the directory of the current file (vim-vinegar style)
  -- No root concept — freely navigate any directory
  -- Delete line = delete file, add line = create file, edit line = rename
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    lazy = false,   -- load immediately (recommended by author)
    opts = {
      default_file_explorer = false,  -- keep netrw disabled, don't replace it
      columns = { "icon", "size" },
      view_options = {
        show_hidden = true,           -- show dotfiles
      },
      float = {
        padding = 2,
        max_width = 80,
        max_height = 30,
      },
      use_default_keymaps = false,  -- disable defaults to prevent conflicts
                                    -- (<C-h> default conflicts with window nav)
      keymaps = {
        ["<CR>"]  = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["gs"]    = "actions.change_sort",
        ["g."]    = "actions.toggle_hidden",
        ["gf"]    = "actions.open_terminal",
        ["gr"]    = "actions.refresh",
        ["q"]     = "actions.close",
        ["?"]     = "actions.show_help",
        -- <C-h> intentionally omitted — conflicts with <C-w>h (window left)
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      -- - opens oil for current file's directory
      vim.keymap.set("n", "-", "<cmd>Oil<CR>",
        { desc = "oil: open parent directory" })
      -- <leader>- opens oil as a floating window
      vim.keymap.set("n", "<leader>-", "<cmd>Oil --float<CR>",
        { desc = "oil: open parent directory (float)" })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("config.nvim-tree")
    end,
  },
  -- NERDTree: classic VimScript file explorer
  -- Key advantage over nvim-tree: :NERDTreeFind reveals file WITHOUT changing root
  -- Use <leader>nf to reveal current file anywhere on disk
  {
    "preservim/nerdtree",
    cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind", "NERDTreeFocus" },
    init = function()
      -- Keymaps must be in init (runs at startup) not config (runs after load)
      -- because NERDTree is lazy-loaded via cmd
      vim.keymap.set("n", "<leader>nn", "<cmd>NERDTreeToggle<CR>",
        { silent = true, desc = "NERDTree: toggle" })
      vim.keymap.set("n", "<leader>nf", "<cmd>NERDTreeFind<CR>",
        { silent = true, desc = "NERDTree: reveal current file" })
      vim.keymap.set("n", "<leader>nF", "<cmd>NERDTreeFocus<CR>",
        { silent = true, desc = "NERDTree: focus" })
    end,
    config = function()
      require("config.nerdtree")
    end,
  },
  {
    "liuchengxu/vista.vim",
    enabled = function()
      return utils.executable("ctags")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- ─── Git ──────────────────────────────────────────────────────────────────────
  {
    "tpope/vim-fugitive",
    event = "User InGitRepo",
    config = function()
      require("config.fugitive")
    end,
  },
  {
    "NeogitOrg/neogit",
    event = "User InGitRepo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("config.neogit")
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("config.git-conflict")
    end,
  },
  {
    "ruifm/gitlinker.nvim",
    event = "User InGitRepo",
    config = function()
      require("config.git-linker")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    version = "*",
    config = function()
      require("config.gitsigns")
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
  },

  -- ─── Editing Enhancements ─────────────────────────────────────────────────────

  -- ack.vim: search across files using ack (or ripgrep as backend)
  -- Falls back to ripgrep (rg) automatically if ack is not installed.
  -- Keymaps:
  --   <leader>ak   search word under cursor across project
  --   <leader>akk  open empty Ack prompt (type pattern manually)
  --   v + <leader>ak  search visual selection across project
  {
    "mileszs/ack.vim",
    cmd = { "Ack", "AckFile", "AckHelp", "AckWindow" },
    keys = {
      { "<leader>ak",  mode = "n" },
      { "<leader>ak",  mode = "v" },
      { "<leader>akk", mode = "n" },
    },
    config = function()
      require("config.ack")
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "BufEnter",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
          require("ts_context_commentstring").setup { enable_autocmd = false }
        end,
      },
    },
    config = function()
      require("config.comment")
    end,
  },
  { "machakann/vim-swap",    event = "VeryLazy" },
  { "tpope/vim-repeat",      event = "VeryLazy" },
  { "tpope/vim-eunuch" },
  { "tpope/vim-obsession",   cmd = "Obsession" },

  -- vim-illuminate: auto-highlight all occurrences of word under cursor.
  -- Useful for tracking variables/functions across long kernel functions.
  -- Uses LSP (highest priority), then treesitter, then regex as fallback.
  -- Navigate between occurrences with ]r / [r
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure {
        providers = { "lsp", "treesitter", "regex" },
        delay = 200,
        under_cursor = true,
        min_count_to_highlight = 2,  -- only highlight if 2+ occurrences
        filetypes_denylist = { "NvimTree", "fugitive", "help", "qf" },
      }
      vim.keymap.set("n", "]r", function() require("illuminate").goto_next_reference() end,
        { desc = "illuminate: next reference" })
      vim.keymap.set("n", "[r", function() require("illuminate").goto_prev_reference() end,
        { desc = "illuminate: prev reference" })
    end,
  },

  -- trouble.nvim: better diagnostics, quickfix, LSP references list UI.
  -- Replaces the plain quickfix/loclist window with a structured, navigable panel.
  -- :Trouble diagnostics   — project-wide LSP errors/warnings
  -- :Trouble lsp           — LSP references, definitions, implementations
  -- :Trouble qflist        — quickfix list in trouble UI
  -- <leader>xx  toggle diagnostics  |  <leader>xq  quickfix  |  <leader>xl  loclist
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",
        desc = "trouble: project diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "trouble: buffer diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",
        desc = "trouble: location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",
        desc = "trouble: quickfix list" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<CR>",
        desc = "trouble: symbols" },
    },
    opts = {
      focus = true,
      warn_no_results = false,
    },
  },
  { "andymass/vim-matchup",  event = "BufRead" },
  { "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } },
  {
    "gbprod/yanky.nvim",
    cmd = "YankyRingHistory",
    config = function()
      require("config.yanky")
    end,
  },
  {
    "nvim-zh/better-escape.vim",
    event = "InsertEnter",
    init = function() require("config.better_escape").init() end,
    config = function() require("config.better_escape").setup() end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    config = function()
      require("config.which-key")
    end,
  },
  { "jdhao/whitespace.nvim", event = "VeryLazy" },
  {
    "smjonas/live-command.nvim",
    event = "CmdlineEnter",
    config = function()
      require("config.live-command")
    end,
  },

  -- ─── TODO Comments ────────────────────────────────────────────────────────────
  -- Highlights and lets you jump to TODO / FIXME / HACK / NOTE / BUG etc.
  -- ]t / [t  jump to next / previous todo comment
  -- <leader>ft  list all TODOs via fzf-lua
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    config = function(_, opts)
      require("todo-comments").setup(opts)
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end,
        { desc = "Next TODO comment" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end,
        { desc = "Prev TODO comment" })
      vim.keymap.set("n", "<leader>ft", "<cmd>TodoFzfLua<CR>",
        { desc = "Find TODOs" })
    end,
  },

  -- ─── Project-wide Find & Replace ──────────────────────────────────────────────
  -- :GrugFar opens the interactive panel; supports ripgrep flags and regex
  -- <leader>rp   open panel   |   <leader>rw  pre-fill with word under cursor
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    config = function()
      require("grug-far").setup {}
      vim.keymap.set("n", "<leader>rp", "<cmd>GrugFar<CR>",
        { desc = "Project find & replace" })
      vim.keymap.set("n", "<leader>rw", function()
        require("grug-far").open { prefills = { search = vim.fn.expand("<cword>") } }
      end, { desc = "Project replace (word under cursor)" })
      vim.keymap.set("v", "<leader>rp", function()
        require("grug-far").with_visual_selection {}
      end, { desc = "Project replace (selection)" })
    end,
  },

  -- ─── Debug (DAP) ──────────────────────────────────────────────────────────────
  -- Install adapters as needed:
  --   pip install debugpy          → Python
  --   apt install lldb             → C/C++ (lldb-dap / lldb-vscode)
  -- Keymaps (normal mode):
  --   <leader>dc  continue       <leader>db  toggle breakpoint
  --   <leader>do  step over      <leader>di  step into
  --   <leader>dO  step out       <leader>du  toggle DAP UI
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver",
            "DapStepInto", "DapStepOut", "DapTerminate" },
    config = function()
      require("config.dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("config.dap-ui")
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("dap-python").setup(vim.fn.exepath("python3"))
    end,
  },

  -- ─── Cscope ───────────────────────────────────────────────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    event = "BufEnter",
    config = function()
      require("config.cscope")
    end,
  },

  -- ─── Markdown ─────────────────────────────────────────────────────────────────
  -- Editing enhancements: folding, TOC, list continuation, table format
  {
    "preservim/vim-markdown",
    ft = { "markdown" },
    dependencies = { "godlygeek/tabular" },
    config = function()
      vim.g.vim_markdown_folding_disabled     = 1  -- use nvim-ufo instead
      vim.g.vim_markdown_conceal              = 0  -- render-markdown.nvim handles this
      vim.g.vim_markdown_conceal_code_blocks  = 0
      vim.g.vim_markdown_follow_anchor        = 1
      vim.g.vim_markdown_auto_insert_bullets  = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      vim.g.vim_markdown_toc_autofit          = 1
    end,
  },
  -- Live preview in browser (requires node/npm)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_preview_options = {
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
      }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>",
            { buffer = true, silent = true, desc = "markdown preview toggle" })
        end,
      })
    end,
  },
  -- Better markdown rendering inside nvim (conceals syntax, renders tables)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {},
    config = function()
      require("render-markdown").setup {}
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>",
            { buffer = true, silent = true, desc = "toggle markdown rendering" })
        end,
      })
    end,
  },

}

---@diagnostic disable-next-line: missing-fields
require("lazy").setup {
  spec = plugin_specs,
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    title_pos = "center",
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
}
