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
  { "<leader>m",  group = "meson build / mark" },
  { "<leader>mk", group = "mark (vim-mark)" },
  { "<leader>r",  group = "replace / rename" },
  { "<leader>w",  group = "LSP workspace" },
  { "<leader>x",  group = "trouble / diagnostics" },
  { "<leader>ak", group = "ack search" },
  { "<leader>n",  group = "file explorer (NERDTree)" },
  { "<leader>t",  group = "toggle" },
  { "<leader>u",  group = "UI toggles" },
}
