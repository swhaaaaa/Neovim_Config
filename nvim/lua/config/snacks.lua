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
  -- Smooth scrolling for <C-d>/<C-u>/<C-f>/<C-b>/gg/G/zz etc.
  scroll = { enabled = true },
  -- Floating lazygit window (requires lazygit on PATH).
  lazygit = { enabled = true },
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
        { icon = " ", key = "s", desc = "Git Status",  action = ":Neogit" },
        { icon = " ", key = "n", desc = "New File",     action = ":enew" },
        { icon = "󰒲 ", key = "L", desc = "Lazy",         action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
      },
    },
  },
}

vim.keymap.set("n", "<leader>gl", function() snacks.lazygit() end,
  { desc = "lazygit", silent = true })

-- Close the dashboard window when a real file is opened (e.g. via NerdTree).
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win)
          and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard"
        then
          pcall(vim.api.nvim_win_close, win, false)
        end
      end
    end)
  end,
})
