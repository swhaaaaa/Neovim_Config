-- lua/config/dap-ui.lua
local ok_dap, dap   = pcall(require, "dap")
local ok_ui,  dapui = pcall(require, "dapui")
if not (ok_dap and ok_ui) then return end

dapui.setup {
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  layouts = {
    {
      elements = {
        { id = "scopes",      size = 0.35 },
        { id = "breakpoints", size = 0.15 },
        { id = "stacks",      size = 0.30 },
        { id = "watches",     size = 0.20 },
      },
      size     = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl",    size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size     = 10,
      position = "bottom",
    },
  },
  floating = {
    border   = "single",
    mappings = { close = { "q", "<Esc>" } },
  },
}

-- Auto open/close the UI when a debug session starts/ends
dap.listeners.after.event_initialized["dapui_config"] = function()
  local code_win = vim.api.nvim_get_current_win()
  dapui.open {}
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(code_win) then
      vim.api.nvim_set_current_win(code_win)
    end
  end)
end
-- TermOpen autocmd (custom-autocmd.lua) calls startinsert for all terminals,
-- including the DAP REPL. Force normal mode whenever the debugger stops.
dap.listeners.after.event_stopped["dapui_config"]      = function()
  vim.schedule(function() vim.cmd("stopinsert") end)
end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close {} end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close {} end

-- Toggle DAP UI manually
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: toggle UI" })
