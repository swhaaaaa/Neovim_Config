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
      -- LuaSnip as primary snippet engine
      {
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          -- Load friendly-snippets (VSCode format)
          require("luasnip.loaders.from_vscode").lazy_load()
          -- Load custom snippets from lua/snippets/ (replaces my_snippets/ + UltiSnips)
          require("luasnip.loaders.from_lua").lazy_load({
            paths = vim.fn.stdpath("config") .. "/lua/snippets",
          })
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
    },
    config = function()
      require("config.nvim-cmp")
    end,
  },

  -- ─── LSP ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        -- Automatically installs missing LSP servers via Mason.
        -- automatic_enable=false: our lsp.lua enable loop stays in charge;
        -- Mason just ensures the server executables exist on disk.
        opts = {
          ensure_installed = {
            "pyright", "ruff", "lua_ls", "clangd", "vimls", "bashls", "yamlls",
            "rust_analyzer",
          },
          automatic_enable = false,
        },
      },
    },
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
    keys = {
      { "<leader>ld", "<cmd>Glance definitions<cr>",     desc = "LSP: peek definitions" },
      { "<leader>lr", "<cmd>Glance references<cr>",      desc = "LSP: peek references" },
      { "<leader>li", "<cmd>Glance implementations<cr>", desc = "LSP: peek implementations" },
    },
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
  -- inc-rename.nvim: live-preview LSP rename — shows all references updating
  -- as you type the new name, before committing. Replaces vim.lsp.buf.rename.
  -- Keymap: <leader>rn  (same key, upgraded behaviour)
  {
    "smjonas/inc-rename.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- nvim-lint: async linting complement to conform.nvim (formatting).
  -- Covers filetypes where LSP diagnostics are absent or insufficient.
  -- Add linters per ft as needed; install them via Mason or system package manager.
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      require("config.nvim-lint")
    end,
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
        rust       = { "rustfmt" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        yaml       = { "prettier" },
        -- Install: :MasonInstall shfmt  or  apt install shfmt
        sh         = { "shfmt" },
        bash       = { "shfmt" },
      },
      format_on_save = function()
        if vim.g.format_on_save then
          return { lsp_format = "fallback", timeout_ms = 500 }
        end
      end,
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
    keys = {
      { "<leader>ux", function() require("treesitter-context").toggle() end,                  desc = "toggle treesitter context" },
      { "[C",         function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "jump to context (treesitter)" },
    },
    opts = {
      enable            = true,
      max_lines         = 3,   -- max lines the context window can take
      min_window_height = 20,  -- don't show in very short windows
      line_numbers      = true,
      multiline_threshold = 1, -- only show single-line context entries
      trim_scope        = "outer",
      mode              = "topline",
      separator         = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
    end,
  },
  -- nvim-treesitter-textobjects removed: its plugin/nvim-treesitter-textobjects.vim
  -- still requires nvim-treesitter.configs (old API) which no longer exists.
  -- Use mini.ai or native treesitter keymaps instead.

  -- mini.ai: better textobjects (replaces nvim-treesitter-textobjects)
  -- Adds: a/i + f(unction definition), c(lass), a(rgument), b(racket), q(uote)
  -- Usage: daf=delete function, yif=yank body, vac=select class, caa=change arg
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- Provides @function.outer / @class.outer query files used by gen_spec.treesitter.
      -- Not configured via nvim-treesitter.configs — loaded only for its runtimepath queries.
      { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
    },
    config = function()
      local ai = require("mini.ai")

      -- @function.outer / @class.outer captures start at the first token, not at
      -- column 1, so plain daf leaves behind the leading indentation.  Wrapping
      -- the spec and setting vis_mode="V" on 'a' regions makes daf/dac delete
      -- whole lines, eliminating the leftover whitespace.
      local function ts_linewise(outer_cap, inner_cap)
        local spec = ai.gen_spec.treesitter({ a = outer_cap, i = inner_cap })
        return function(ai_type, id, opts)
          local regions = spec(ai_type, id, opts)
          if ai_type == "a" and regions then
            for _, r in ipairs(regions) do
              r.vis_mode = "V"
            end
          end
          return regions
        end
      end

      ai.setup {
        n_lines = 500,
        -- Remap 'around/inside last' from 'al'/'il' to 'aL'/'iL' so that the
        -- two-char 'al' binding doesn't shadow our custom 'l' (loop) textobject.
        -- mini.ai docs recommend this pattern to avoid conflicts with Neovim builtins.
        mappings = {
          around_last = "aL",
          inside_last = "iL",
        },
        custom_textobjects = {
          f = ts_linewise("@function.outer",    "@function.inner"),
          c = ts_linewise("@class.outer",       "@class.inner"),
          l = ts_linewise("@loop.outer",        "@loop.inner"),
          o = ts_linewise("@conditional.outer", "@conditional.inner"),
        },
      }
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
    event = "BufReadPost",
    opts = {
      user_default_options = {
        names = false,  -- CSS color names ("blue", "red") cause false positives in non-CSS files
      },
    },
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
    "folke/snacks.nvim",
    priority = 1000,  -- load early so vim.notify is overridden before other plugins use it
    lazy = false,
    config = function()
      require("config.snacks")
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
  -- smart-splits.nvim: <C-hjkl> move between splits like plain <C-w>hjkl, but
  -- also cross seamlessly into tmux panes when the cursor is at the edge of
  -- the Neovim window. Requires companion tmux keybindings (see plugin docs'
  -- tmux integration section) — without them this just behaves like the old
  -- <C-w>hjkl mappings it replaces.
  -- Loaded on VeryLazy rather than key-triggered lazy-loading: the tmux side
  -- decides whether to forward <C-hjkl> into Neovim or switch panes directly
  -- based on the `@pane-is-vim` tmux variable, which this plugin only sets
  -- once it has actually loaded — key-triggered lazy-loading would leave that
  -- variable unset until the first <C-h> press from inside Neovim.
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    config = function()
      require("config.smart-splits")
    end,
  },
  -- flash.nvim: replaces hop.nvim. Enhances native f/F/t/T in place (no
  -- remapping needed — it hooks the built-in motions directly) and adds
  -- s/S for ad-hoc 2-char label jumps and treesitter-node selection.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          jump_labels = true,  -- show hint labels on f/F/t/T when ambiguous
        },
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,            desc = "flash: jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,       desc = "flash: treesitter select" },
      { "r",     mode = "o",               function() require("flash").remote() end,           desc = "flash: remote" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "flash: treesitter search" },
      -- search-mode toggle (<C-s>/<C-x>) intentionally not bound — confusing
      -- as a manual toggle; plain incsearch is used for "/" instead.
    },
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
  -- oil.nvim: edit filesystem like a buffer
  -- Press - to open the directory of the current file (vim-vinegar style)
  -- No root concept — freely navigate any directory
  -- Delete line = delete file, add line = create file, edit line = rename
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    lazy = false,   -- load immediately (recommended by author)
    opts = {
      default_file_explorer = true,   -- disables netrw so it can't intercept oil:// paths
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
      vim.keymap.set("n", "-", "<cmd>Oil<CR>",
        { desc = "oil: open parent directory" })
      vim.keymap.set("n", "<leader>-", "<cmd>Oil --float<CR>",
        { desc = "oil: open parent directory (float)" })
    end,
  },
  -- nvim-tree: tree-view file explorer (companion to oil.nvim)
  -- oil handles file editing/renaming; nvim-tree handles tree browsing
  -- Inside the tree: o/<CR> open, E expand-all, W collapse-all, a create,
  --                  d delete, r rename, H toggle hidden, I toggle git-ignored, ? help
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-mini/mini.icons" },
    cmd  = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus" },
    keys = {
      { "<leader>nn", "<cmd>NvimTreeToggle<CR>",   desc = "nvim-tree: toggle" },
      { "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "nvim-tree: reveal current file" },
      { "<leader>nF", "<cmd>NvimTreeFocus<CR>",    desc = "nvim-tree: focus" },
    },
    config = function()
      require("config.nvim-tree")
    end,
  },
  -- aerial.nvim: LSP/treesitter symbol outline (no ctags required)
  -- Must load on BufReadPost so it registers its LSP on_attach hook before
  -- language servers attach — otherwise symbols are never populated.
  -- Toggle: <leader>ao
  {
    "stevearc/aerial.nvim",
    event = "BufReadPost",
    keys = { { "<leader>ao", "<cmd>AerialToggle<CR>", desc = "aerial: toggle symbol outline" } },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    config = function()
      require("config.aerial")
    end,
  },

  -- harpoon2: mark up to 4 files per project and jump to them with one keypress.
  -- Marks persist across sessions (stored in stdpath("data")/harpoon/).
  -- <leader>Ha  add current file  |  <leader>Hh  open menu (editable)
  -- <leader>1/2/3/4  jump directly to slot 1–4
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>Ha", function() require("harpoon"):list():add() end,                                            desc = "harpoon: add file" },
      { "<leader>Hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end,            desc = "harpoon: menu" },
      { "<leader>1",  function() require("harpoon"):list():select(1) end,                                        desc = "harpoon: jump to 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end,                                        desc = "harpoon: jump to 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end,                                        desc = "harpoon: jump to 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end,                                        desc = "harpoon: jump to 4" },
    },
    opts = {},
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
    event = "User InGitRepo",
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
      { "<leader>akr", mode = "n" },
      { "<leader>akc", mode = "n" },
    },
    config = function()
      require("config.ack")
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
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
  { "tpope/vim-eunuch", event = "VeryLazy" },
  {
    "tpope/vim-obsession",
    cmd  = "Obsession",
    keys = {
      { "<leader>ss", "<cmd>Obsession<CR>",          desc = "session: toggle recording (obsession)" },
      { "<leader>sr", function()
          if vim.fn.filereadable("Session.vim") == 1 then
            vim.cmd("source Session.vim")
          else
            vim.notify("No Session.vim in cwd", vim.log.levels.WARN)
          end
        end, desc = "session: restore from Session.vim" },
    },
  },

  -- vim-illuminate: auto-highlight all occurrences of word under cursor.
  -- Useful for tracking variables/functions across long kernel functions.
  -- Uses LSP (highest priority), then treesitter, then regex as fallback.
  -- Navigate between occurrences with ]r / [r
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    keys = {
      { "]r", function() require("illuminate").goto_next_reference() end, desc = "illuminate: next reference" },
      { "[r", function() require("illuminate").goto_prev_reference() end, desc = "illuminate: prev reference" },
    },
    config = function()
      require("illuminate").configure {
        providers = { "lsp", "treesitter", "regex" },
        delay = 200,
        under_cursor = true,
        min_count_to_highlight = 2,  -- only highlight if 2+ occurrences
        filetypes_denylist = { "NvimTree", "fugitive", "help", "qf", "aerial" },
      }
    end,
  },

  -- vim-mark: highlight multiple words simultaneously in different colors
  -- <leader>mk  toggle highlight word under cursor (n/v)
  -- <leader>mK  clear all marks
  -- {N}<leader>mk  mark with specific color N (1-6)
  {
    "inkarkat/vim-mark",
    dependencies = { "inkarkat/vim-ingo-library" },
    keys = {
      { "<leader>mk", "<Plug>MarkSet",      mode = { "n", "v" }, desc = "Mark: toggle mark" },
      { "<leader>mK", "<Plug>MarkAllClear", mode = "n",          desc = "Mark: clear all" },
    },
    init = function()
      -- Must be set before plugin loads to disable default mappings
      vim.g.mw_no_mappings = 1
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
  {
    "simnalamburt/vim-mundo",
    cmd  = { "MundoToggle", "MundoShow" },
    keys = { { "<leader>um", "<cmd>MundoToggle<CR>", desc = "toggle undo tree" } },
  },
  {
    "gbprod/yanky.nvim",
    cmd = "YankyRingHistory",
    keys = { "p", "P", "[y", "]y", { "<leader>fy", "<cmd>YankyRingHistory<CR>", desc = "yank ring history" } },
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
  -- <leader>ft  list all TODOs via fzf-lua  |  <leader>fB  buffer tags (ctags)
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO comment" },
      { "<leader>ft", "<cmd>TodoFzfLua<CR>",                               desc = "Find TODOs" },
    },
    opts = {},
    config = function(_, opts)
      require("todo-comments").setup(opts)
    end,
  },

  -- ─── Project-wide Find & Replace ──────────────────────────────────────────────
  -- :GrugFar opens the interactive panel; supports ripgrep flags and regex
  -- <leader>rp   open panel   |   <leader>rw  pre-fill with word under cursor
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>rp", "<cmd>GrugFar<CR>",                                        desc = "Project find & replace" },
      { "<leader>rw", function()
          require("grug-far").open { prefills = { search = vim.fn.expand("<cword>") } }
        end,                                                                      desc = "Project replace (word under cursor)" },
      { "<leader>rp", function() require("grug-far").with_visual_selection {} end,
        mode = "v",                                                               desc = "Project replace (selection)" },
    },
    config = function()
      require("grug-far").setup {}
    end,
  },

  -- ─── Task Runner ──────────────────────────────────────────────────────────────
  -- overseer.nvim: async task runner and job orchestrator
  -- Unifies build/test/lint workflows with a persistent task list panel.
  -- Keymaps: <leader>ot (toggle panel), <leader>or (run task template),
  --          <leader>oR (run shell cmd via OverseerShell)
  {
    "stevearc/overseer.nvim",
    cmd  = { "OverseerToggle", "OverseerRun", "OverseerShell", "OverseerTaskAction" },
    keys = {
      { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "overseer: toggle task list" },
      { "<leader>or", "<cmd>OverseerRun<CR>",    desc = "overseer: run task template" },
      { "<leader>oR", "<cmd>OverseerShell<CR>",  desc = "overseer: run shell command" },
    },
    config = function()
      require("config.overseer")
    end,
  },

  -- ─── Terminal ─────────────────────────────────────────────────────────────────
  -- toggleterm.nvim: persistent floating/split terminal, toggled by <leader>tt.
  -- <Esc><Esc> exits terminal mode back to normal mode.
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd  = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "toggle floating terminal" },
    },
    config = function()
      require("config.toggleterm")
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
    keys = {
      { "<leader>dc", desc = "DAP: continue" },
      { "<leader>do", desc = "DAP: step over" },
      { "<leader>di", desc = "DAP: step into" },
      { "<leader>dO", desc = "DAP: step out" },
      { "<leader>db", desc = "DAP: toggle breakpoint" },
      { "<leader>dB", desc = "DAP: conditional breakpoint" },
      { "<leader>dL", desc = "DAP: log point" },
      { "<leader>dr", desc = "DAP: open REPL" },
      { "<leader>dl", desc = "DAP: run last" },
      { "<leader>dx", desc = "DAP: terminate" },
    },
    config = function()
      require("config.dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    event = "VeryLazy",
    keys = { { "<leader>du", desc = "toggle DAP UI" } },
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
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    opts = {
      commented = true,   -- prefix virtual text with comment string
    },
  },

  -- mason-nvim-dap: auto-installs DAP adapters via Mason (same role as
  -- mason-lspconfig for LSP servers). handlers = no-op so dap.lua keeps
  -- full control of adapter configuration.
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    event = "VeryLazy",
    opts = {
      -- "python" is mason-nvim-dap's adapter name; it maps internally to
      -- the "debugpy" Mason package. Using "debugpy" directly here is a
      -- silent no-op since it's not a recognized adapter name.
      ensure_installed = { "codelldb", "python" },
      handlers = { function() end },  -- dap.lua handles all adapter config
    },
  },

  -- ─── Cscope ───────────────────────────────────────────────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    event = "VeryLazy",
    config = function()
      require("config.cscope")
    end,
  },

  -- ─── AI Assistant ─────────────────────────────────────────────────────────────
  -- claudecode.nvim: connects Neovim to Claude Code CLI via WebSocket.
  -- Same experience as the VS Code extension. Requires Claude Code CLI:
  --   npm install -g @anthropic-ai/claude-code  then  claude  (to authenticate)
  -- Keymaps: <leader>A prefix (uppercase, separate from clangd's <leader>a)
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    keys = {
      { "<leader>Ac", "<cmd>ClaudeCode<cr>",            desc = "Claude: toggle" },
      { "<leader>Af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Claude: focus" },
      { "<leader>Ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Claude: resume" },
      { "<leader>AC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue" },
      { "<leader>Am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
      { "<leader>Ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Claude: add current buffer" },
      { "<leader>As", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>Aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Claude: accept diff" },
      { "<leader>Ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Claude: deny diff" },
    },
    opts = {
      auto_start  = true,
      track_selection = true,
      terminal = {
        split_side           = "right",
        split_width_percentage = 0.35,
        provider             = "snacks",
        auto_close           = true,
        -- <Esc> passes through to Claude (needed for /cost, menus, etc.).
        -- <C-e> exits terminal mode without sending anything to Claude.
        -- <C-u>/<C-d> scroll are handled by the TermOpen autocmd in custom-autocmd.lua.
        -- (<C-\><C-n> is also always available as the built-in Neovim terminal escape)
        snacks_win_opts = {
          keys = {
            term_escape = {
              "<C-e>",
              function() vim.cmd("stopinsert") end,
              mode = "t",
              desc = "Exit terminal mode (back to Neovim)",
            },
          },
        },
      },
    },
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
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "markdown preview toggle" },
    },
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_preview_options = {
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
      }
    end,
  },
  -- Better markdown rendering inside nvim (conceals syntax, renders tables)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "toggle markdown rendering" },
    },
    config = function()
      require("render-markdown").setup {}
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
