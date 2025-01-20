return {
  -- Colorscheme
  {
    "tanvirtin/monokai.nvim",
  },

  -- LSP manager
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },

  -- Add hooks to LSP to support Linter && Formatter
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      -- Note:
      --     the default search path for `require` is ~/.config/nvim/lua
      --     use a `.` as a path seperator
      --     the suffix `.lua` is not needed
      require("configs.mason-null-ls")
    end,
  },

  -- Vscode-like pictograms
  {
    "onsails/lspkind.nvim",
    event = { "VimEnter" },
  },

  -- Auto-completion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "lspkind.nvim" },
    config = function()
      require("configs.cmp")
    end,
  },
  { "hrsh7th/cmp-nvim-lsp", dependencies = { "nvim-cmp" } },
  { "hrsh7th/cmp-buffer", dependencies = { "nvim-cmp" } }, -- buffer auto-completion
  { "hrsh7th/cmp-path", dependencies = { "nvim-cmp" } }, -- path auto-completion
  { "hrsh7th/cmp-cmdline", dependencies = { "nvim-cmp" } }, -- cmdline auto-completion
  {
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lua",
  },

  -- Code snippet engine
  --{
    --"L3MON4D3/LuaSnip",
    --version = "v2.*",
  --},
    {
      -- snippet plugin
      "L3MON4D3/LuaSnip",
      dependencies = "rafamadriz/friendly-snippets",
      opts = { history = true, updateevents = "TextChanged,TextChangedI" },
      config = function(_, opts)
	require("luasnip").config.set_config(opts)
	require "configs.luasnip"
      end,
    },

  -- Better UI
  -- Run `:checkhealth noice` to check for common issues
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },

  --{
    --"folke/which-key.nvim",
    --event = "VeryLazy",
    --init = function()
      --vim.o.timeout = true
      --vim.o.timeoutlen = 300
    --end,
    --opts = {
      ---- your configuration comes here
      ---- or leave it empty to use the default settings
      ---- refer to the configuration section below
    --}
  --},

  -- Git integration
  {
    "tpope/vim-fugitive",
  },
  -- Git decorations
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("configs.gitsigns")
    end,
  },

  -- Autopairs: [], (), "", '', etc
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
	    require("configs.autopairs")
    end,
  },

  -- Treesitter-integration
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("configs.treesitter")
    end,
  },

  -- Nvim-treesitter text objects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("configs.treesitter-textobjects")
    end,
  },

  -- Show indentation and blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("configs.indent-blankline")
    end,
  },
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("configs.lualine")
    end,
  },

  -- Markdown support
  { "preservim/vim-markdown", ft = { "markdown" } },
  -- Markdown previewer
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  -- File explorer
  --{
    --"nvim-tree/nvim-tree.lua",
    --dependencies = {
      --"nvim-tree/nvim-web-devicons", -- optional, for file icons
    --},
    --config = function()
      --require("configs.nvim-tree")
    --end,
  --},
  --
  -- Nerdtree
  {
    "preservim/nerdtree",
  },

  -- Smart motion
  -- Usage: Enter 2-character search pattern then press a label character to
  --        pick your target.
  --        Initiate the sesarch with `s`(forward) or `S`(backward)
  {
    "ggandor/leap.nvim",
    config = function()
      -- See `:h leap-custom-mappings` for more details
      require("leap").create_default_mappings()
    end,
  },

  -- Make surrounding easier
  -- ------------------------------------------------------------------
  -- Old text                    Command         New text
  -- ------------------------------------------------------------------
  -- surr*ound_words             gziw)           (surround_words)
  -- *make strings               gz$"            "make strings"
  -- [delete ar*ound me!]        gzd]            delete around me!
  -- remove <b>HTML t*ags</b>    gzdt            remove HTML tags
  -- 'change quot*es'            gzc'"           "change quotes"
  -- delete(functi*on calls)     gzcf            function calls
  -- ------------------------------------------------------------------
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    -- You can use the VeryLazy event for things that can
    -- load later and are not important for the initial UI
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
	-- To solve the conflicts with leap.nvim
	-- See: https://github.com/ggandor/leap.nvim/discussions/59
	keymaps = {
	  insert = "<C-g>z",
	  insert_line = "gC-ggZ",
	  normal = "gz",
	  normal_cur = "gZ",
	  normal_line = "gzgz",
	  normal_cur_line = "gZgZ",
	  visual = "gz",
	  visual_line = "gZ",
	  delete = "gzd",
	  change = "gzc",
	},
      })
    end,
  },
  -- Better terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("configs.toggleterm")
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    opts = function()
      return require "configs.telescope"
    end,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      telescope.load_extension 'remote-sshfs'
    end,
  },

  {
    "nosduco/remote-sshfs.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("configs.remote-sshfs")
    end,
  },

  -- Ack
  {
    "mileszs/ack.vim",
  },

  -- Tagbar
  {
    "preservim/tagbar",
  },


  -- Code comment helper
  --     1. `gcc` to comment a line
  --     2. select lines in visual mode and run `gc` to comment/uncomment lines
  --{
    --"tpope/vim-commentary",
  --},
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "comment toggle linewise" },
      { "gc", mode = "x", desc = "comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "comment toggle blockwise" },
      { "gb", mode = "x", desc = "comment toggle blockwise (visual)" },
    },
    config = function(_, opts)
      require("Comment").setup(opts)
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

}

