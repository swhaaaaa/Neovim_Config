-- lua/config/neogit.lua
local ok, neogit = pcall(require, "neogit")
if not ok then return end

neogit.setup({
  -- UI
  kind = "auto",               -- "auto" | "tab" | "replace" | "split" | "vsplit" | "floating"
  graph_style = "unicode",     -- nicer ASCII/Unicode graph
  signs = {
    -- tweak if you like
    section = { "", "" },
    item    = { "", "" },
    hunk    = { "", "" },
  },
  mappings = {
    status = {
      ["q"]        = "Close",
      ["<cr>"]     = "Toggle",          -- open/close folds
      ["<tab>"]    = "Toggle",
      ["s"]        = "Stage",
      ["u"]        = "Unstage",
      ["S"]        = "StageAll",
      ["U"]        = "UnstageStaged",
      ["x"]        = "Discard",
      ["j"]        = "MoveDown",
      ["k"]        = "MoveUp",
      ["J"]        = "GoToNextHunkHeader",
      ["K"]        = "GoToPreviousHunkHeader",
    },
  },
  -- Commit editor
  commit_editor = { kind = "auto" },
  disable_commit_confirmation = true,   -- skip the “are you sure?” dialog
  remember_settings = true,

  -- Integrations
  telescope = true,
  integrations = { diffview = true },

  -- Behaviour
  auto_refresh = true,         -- refresh after actions (stage/commit/etc.)
  disable_hint = true,         -- hide inline usage hints
  use_default_keymaps = true,  -- keep Neogit’s built-ins; we’ll add a few more below
})

-- --------------------------------------------------------------------
-- Global keymaps (normal mode)
-- --------------------------------------------------------------------
local map = vim.keymap.set
local function desc(d) return { desc = d, silent = true } end

-- Open Neogit (status view)
map("n", "<leader>gg", function()
  neogit.open({ kind = "split" })   -- change to "tab" or "floating" if you prefer
end, desc("Neogit: status"))

-- Popups (commit / push / pull / rebase / log)
map("n", "<leader>ggc", "<cmd>Neogit commit<CR>",                 desc("Neogit: commit popup"))
map("n", "<leader>ggp", "<cmd>Neogit push<CR>",                   desc("Neogit: push popup"))
map("n", "<leader>ggP", "<cmd>Neogit pull<CR>",                   desc("Neogit: pull popup"))
map("n", "<leader>ggr", "<cmd>Neogit rebase<CR>",                 desc("Neogit: rebase popup"))
map("n", "<leader>ggl", "<cmd>Neogit log<CR>",                    desc("Neogit: log popup"))

-- Handy one-shots
-- Amend last commit (edit message)
map("n", "<leader>ggA", "<cmd>Neogit commit --amend<CR>",         desc("Neogit: amend last commit"))
-- Amend without opening editor (keep same message)
map("n", "<leader>gga", "<cmd>Neogit commit --amend --no-edit<CR>", desc("Neogit: amend (no edit)"))

-- Start an interactive rebase for the last N commits (prompt for N)
map("n", "<leader>ggR", function()
  local n = vim.fn.input("Interactive rebase HEAD~")
  if n ~= "" then
    vim.cmd("Neogit rebase --interactive HEAD~" .. n)
  end
end, desc("Neogit: rebase -i HEAD~N"))

-- Optional: close Neogit buffers with 'q'
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NeogitStatus", "NeogitCommitMessage" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>quit<CR>", { buffer = ev.buf, silent = true })
  end,
})

