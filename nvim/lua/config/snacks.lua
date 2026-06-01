local ok, snacks = pcall(require, "snacks")
if not ok then return end
snacks.setup {
  notifier = {
    enabled  = true,
    timeout  = 1500,
    style    = "fancy",   -- icon + title bar; alternatives: "compact", "minimal"
    top_down = false,     -- stack notifications from the bottom-right up
  },
  -- Nicer vim.ui.input (used by LSP rename, input prompts, etc.)
  input = { enabled = true },
  -- Startup dashboard: shown when nvim is opened with no file arguments.
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys",         gap = 1, padding = 1 },
      { section = "recent_files", indent = 2, padding = 1, limit = 8 },
      { section = "startup" },
    },
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File",    action = ":FzfLua files" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
        { icon = " ", key = "g", desc = "Live Grep",    action = ":FzfLua live_grep" },
        { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end },
        { icon = " ", key = "n", desc = "New File",     action = ":enew" },
        { icon = "󰒲 ", key = "L", desc = "Lazy",         action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
      },
    },
  },
}
