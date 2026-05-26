local wk = require("which-key")

wk.setup {
  preset = "modern",
  icons  = { mappings = false },
}

-- ── Group labels ──────────────────────────────────────────────────────────
-- These appear as section headers in the which-key popup when you pause
-- after pressing the leader key or a prefix.
wk.add {
  -- leader groups
  { "<leader>a",  group = "C/C++ (clangd)" },
  { "<leader>c",  group = "cscope" },
  { "<leader>d",  group = "debug (DAP)" },
  { "<leader>f",  group = "find (fzf-lua)" },
  { "<leader>g",  group = "git" },
  { "<leader>gg", group = "neogit" },
  { "<leader>h",  group = "git hunks" },
  { "<leader>l",  group = "LSP peek (glance)" },
  { "<leader>m",  group = "meson / mark" },
  { "<leader>mk", group = "mark (vim-mark)" },
  { "<leader>ms", desc = "meson setup" },
  { "<leader>mb", desc = "meson build" },
  { "<leader>ml", desc = "meson re-link" },
  { "<leader>r",  group = "replace / rename" },
  { "<leader>w",  group = "LSP workspace" },
  { "<leader>x",  group = "trouble / diagnostics" },
  { "<leader>ak", group = "ack search" },
  { "<leader>ao", desc = "aerial: toggle symbol outline" },
  { "<leader>n",  group = "file explorer (NERDTree)" },
  { "<leader>t",  group = "toggle" },
  { "<leader>tf", desc = "toggle format on save" },
  { "<leader>fm", desc = "toggle fold method expr/manual" },
  { "<leader>u",  group = "UI toggles" },
  -- UI toggle entries
  { "<leader>ub", desc = "blink cursor to locate it" },
  { "<leader>uc", desc = "pick colorscheme (fzf-lua)" },
  { "<leader>ud", desc = "toggle diagnostics" },
  { "<leader>uD", desc = "toggle diagnostic float balloon" },
  { "<leader>ux", desc = "toggle treesitter context bar" },
  -- DAP entries
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
  { "<leader>du", desc = "toggle DAP UI" },
  -- todo-comments jumps
  { "]t", desc = "next TODO comment" },
  { "[t", desc = "prev TODO comment" },
}
