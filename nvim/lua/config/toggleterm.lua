local ok, toggleterm = pcall(require, "toggleterm")
if not ok then return end

toggleterm.setup {
  direction  = "float",
  float_opts = { border = "curved" },
  shade_terminals = false,
}

-- <Esc> is already mapped globally (mappings.lua) to exit terminal mode for
-- all terminals; no additional binding needed here.
