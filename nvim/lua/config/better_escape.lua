-- lua/config/better_escape.lua
local M = {}

-- Runs before plugin loads (so the plugin sees these)
function M.init()
  -- multiple combos supported
  vim.g.better_escape_shortcut = { "jk", "kj", "jj" }
  -- time window (ms) to treat combo as <Esc>
  vim.g.better_escape_interval = 175
  -- vim.g.better_escape_debug = 1  -- uncomment to debug timings in :messages
end

-- Optional niceties
function M.setup()
  -- Disable better-escape in special prompts where <Esc>-like combos are unwanted
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "TelescopePrompt", "fzf", "noice", "minifiles" },
    callback = function() vim.b.better_escape_disabled = 1 end,
    desc = "Disable better-escape in prompt-like buffers",
  })
end

return M

