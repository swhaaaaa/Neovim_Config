-- lua/config/dap.lua
-- Core nvim-dap setup. Language adapters are registered here when the
-- corresponding tool is found on PATH. Install adapters as needed:
--   pip install debugpy                   (Python)
--   apt install lldb                      (C/C++ → lldb-dap or lldb-vscode)
--   :MasonInstall codelldb                (C/C++ → preferred, better struct pretty-print)

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

-- vim.fn.input() with "file" completion requires the native cmdline UI.
-- snacks.input hooks vim.ui.input and loses tab completion, so temporarily
-- restore the original before calling input() then put snacks back.
local function input_file(prompt, default)
  local orig = vim.ui.input
  vim.ui.input = nil
  local path = vim.fn.input(prompt, default or "", "file")
  vim.ui.input = orig
  return path ~= "" and path or nil
end

-- ── C/C++ configurations (shared by both adapters) ────────────────────────
local c_cpp_cfg = {
  {
    name    = "Launch executable",
    type    = "codelldb",   -- will fall back to lldb if codelldb not found
    request = "launch",
    program = function()
      return input_file("Executable: ", "")
    end,
    cwd         = "${workspaceFolder}",
    stopOnEntry = false,
    args        = {},
  },
  {
    name    = "Launch with args",
    type    = "codelldb",
    request = "launch",
    program = function()
      return input_file("Executable: ", "")
    end,
    args = function()
      local args = vim.fn.input("Args: ")
      return vim.split(args, " ", { trimempty = true })
    end,
    cwd         = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    name    = "Attach to PID",
    type    = "codelldb",
    request = "attach",
    pid     = require("dap.utils").pick_process,
    args    = {},
  },
}

-- ── codelldb adapter (preferred — install via :MasonInstall codelldb) ─────
-- Better than lldb-dap for modern clang builds and kernel struct pretty-print.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
if vim.fn.executable(mason_bin) == 1 or vim.fn.executable("codelldb") == 1 then
  local codelldb_cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or "codelldb"
  dap.adapters.codelldb = {
    type    = "server",
    port    = "${port}",
    executable = {
      command = codelldb_cmd,
      args    = { "--port", "${port}" },
    },
  }
  dap.configurations.c   = c_cpp_cfg
  dap.configurations.cpp = c_cpp_cfg

-- ── LLDB adapter fallback (apt install lldb) ───────────────────────────────
else
  local lldb_exec = vim.fn.executable("lldb-dap") == 1 and "lldb-dap"
                or  vim.fn.executable("lldb-vscode") == 1 and "lldb-vscode"
                or  nil

  if lldb_exec then
    dap.adapters.codelldb = {
      type    = "executable",
      command = lldb_exec,
      name    = "lldb",
    }
    -- remap type to lldb for the fallback adapter
    local lldb_cfg = vim.deepcopy(c_cpp_cfg)
    for _, cfg in ipairs(lldb_cfg) do cfg.type = "codelldb" end
    dap.configurations.c   = lldb_cfg
    dap.configurations.cpp = lldb_cfg
  else
    vim.notify(
      "DAP: no C/C++ adapter found.\n" ..
      "Run :MasonInstall codelldb  or  sudo apt install lldb",
      vim.log.levels.WARN
    )
  end
end

-- ── Ensure normal mode when debugger stops ────────────────────────────────
-- TermOpen autocmd (custom-autocmd.lua) calls startinsert for all terminals,
-- including DAP adapter buffers. Force normal mode on every stopped event.
dap.listeners.after.event_stopped["dap_core"] = function()
  vim.schedule(function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" or mode == "ic" or mode == "ix" then
      vim.cmd("stopinsert")
    elseif mode == "t" then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "n", false
      )
    end
  end)
end

-- ── Python (debugpy) ──────────────────────────────────────────────────────
-- Install via Mason (:MasonInstall debugpy) OR pip install debugpy.
-- Mason binary takes priority; falls back to the pip-installed module.
local mason_debugpy = vim.fn.stdpath("data") .. "/mason/bin/debugpy-adapter"
local debugpy_cmd = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy
                 or vim.fn.executable("debugpy-adapter") == 1 and "debugpy-adapter"
                 or nil

-- Detect active virtualenv at launch time so the right interpreter is used.
local function python_path()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then return venv .. "/bin/python" end
  return "python3"
end

local python_cfg = {
  {
    name       = "Launch file",
    type       = "python",
    request    = "launch",
    program    = "${file}",
    pythonPath = python_path,
    console    = "integratedTerminal",
  },
  {
    name       = "Launch with args",
    type       = "python",
    request    = "launch",
    program    = "${file}",
    pythonPath = python_path,
    args       = function()
      local args = vim.fn.input("Args: ")
      return vim.split(args, " ", { trimempty = true })
    end,
    console    = "integratedTerminal",
  },
}

if debugpy_cmd then
  dap.adapters.python = {
    type    = "executable",
    command = debugpy_cmd,
  }
  dap.configurations.python = python_cfg
elseif vim.fn.executable("python3") == 1 then
  -- Register optimistically — if debugpy isn't installed, DAP will report the
  -- error at launch time (more actionable than a blocking import-check at startup).
  dap.adapters.python = {
    type    = "executable",
    command = "python3",
    args    = { "-m", "debugpy.adapter" },
  }
  dap.configurations.python = python_cfg
else
  vim.notify(
    "DAP: no Python adapter found — python3 not on PATH.\n" ..
    "Install Python3, then: pip install debugpy  or  :MasonInstall debugpy",
    vim.log.levels.WARN
  )
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
map("n", "<leader>dv", function()
  require("nvim-dap-virtual-text").toggle()
end, { desc = "DAP: toggle virtual text" })
