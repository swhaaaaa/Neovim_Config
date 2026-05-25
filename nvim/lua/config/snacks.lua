require("snacks").setup {
  notifier = {
    enabled  = true,
    timeout  = 1500,
    style    = "fancy",   -- icon + title bar; alternatives: "compact", "minimal"
    top_down = false,     -- stack notifications from the bottom-right up
  },
  -- Nicer vim.ui.input (used by LSP rename, input prompts, etc.)
  input = { enabled = true },
}
