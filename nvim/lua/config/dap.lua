-- lua/config/dap.lua
-- Core nvim-dap setup. Language adapters are registered here when the
-- corresponding tool is found on PATH. Install adapters as needed:
--   pip install debugpy          (Python)
--   apt install lldb             (C/C++ → lldb-dap or lldb-vscode)

local ok, dap = pcall(require, "dap")
if not ok then return end

-- ── Signs ──────────────────────────────────────────────────────────────────
vim.fn.sign_define("DapBreakpoint", {
  text = "●", texthl = "DiagnosticError", linehl = "", numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
  text = "◎", texthl = "DiagnosticWarning", linehl = "", numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
  text = "◉", texthl = "DiagnosticInfo", linehl = "", numhl = "",
})
vim.fn.sign_define("DapStopped", {
  text = "▶", texthl = "DiagnosticOk",
  linehl = "DapStoppedLine", numhl = "",
})

-- ── LLDB adapter for C / C++ / Rust ───────────────────────────────────────
-- Supports both the old lldb-vscode and the new lldb-dap binary names.
local lldb_exec = vim.fn.executable("lldb-dap") == 1 and "lldb-dap"
              or  vim.fn.executable("lldb-vscode") == 1 and "lldb-vscode"
              or  nil

if lldb_exec then
  dap.adapters.lldb = {
    type    = "executable",
    command = lldb_exec,
    name    = "lldb",
  }

  local lldb_cfg = {
    {
      name    = "Launch (lldb)",
      type    = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd         = "${workspaceFolder}",
      stopOnEntry = false,
      args        = {},
    },
    {
      name    = "Attach to PID (lldb)",
      type    = "lldb",
      request = "attach",
      pid     = require("dap.utils").pick_process,
      args    = {},
    },
  }
  dap.configurations.c   = lldb_cfg
  dap.configurations.cpp = lldb_cfg
end

-- ── Keymaps ────────────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<leader>dc", dap.continue,          { desc = "DAP: continue" })
map("n", "<leader>do", dap.step_over,          { desc = "DAP: step over" })
map("n", "<leader>di", dap.step_into,          { desc = "DAP: step into" })
map("n", "<leader>dO", dap.step_out,           { desc = "DAP: step out" })
map("n", "<leader>db", dap.toggle_breakpoint,  { desc = "DAP: toggle breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: conditional breakpoint" })
map("n", "<leader>dL", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: log point" })
map("n", "<leader>dr", dap.repl.open,          { desc = "DAP: open REPL" })
map("n", "<leader>dl", dap.run_last,           { desc = "DAP: run last" })
map("n", "<leader>dx", dap.terminate,          { desc = "DAP: terminate" })
