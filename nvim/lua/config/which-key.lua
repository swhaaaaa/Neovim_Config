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
  { "<leader>r",  group = "replace (grug-far)" },
  { "<leader>x",  group = "trouble / diagnostics" },
  { "<leader>ak", group = "ack search" },
  { "<leader>n",  group = "file explorer" },
  { "<leader>t",  group = "toggle" },
  { "<leader>u",  group = "UI toggles" },
  -- space groups
  { "<space>g",   group = "LSP peek (glance)" },
}
