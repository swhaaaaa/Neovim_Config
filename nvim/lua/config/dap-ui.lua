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
dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open {} end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close {} end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close {} end

-- Toggle DAP UI manually
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: toggle UI" })
