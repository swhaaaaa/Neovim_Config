local builtin = require("statuscol.builtin")

-- only show fold level up to this level
local fold_level_limit = 3
local function foldfunc(args)
  local ok, ffi = pcall(require, "statuscol.ffidef")
  if not ok then return builtin.foldfunc(args) end
  local C = ffi.C
  local foldinfo = C.fold_info(args.wp, args.lnum)
  if foldinfo.level > fold_level_limit then
    -- Match builtin.foldfunc's width exactly (it returns "" when
    -- args.fold.width == 0) instead of hardcoding a single space, which
    -- stole a column from the line-number segment's %= fill and shifted
    -- numbers left by one character on every line past this fold depth.
    return (" "):rep(args.fold.width)
  end
  return builtin.foldfunc(args)
end

-- Plugins like treesitter-context (pinned scope lines) and gitsigns (hunk
-- preview) render a gutter for buffer lines that aren't actually on screen by
-- calling nvim_eval_statusline(..., {use_statuscol_lnum = lnum}) on the real
-- window. builtin.lnumfunc can't tell that apart from a normal visible row,
-- so it reports the line's distance from the cursor -- which keeps changing
-- as the cursor moves. Tag those probe calls by wrapping nvim_eval_statusline
-- so lnumfunc can force the absolute line number for them instead.
local in_lno_probe = 0
-- Guard against stacking on :ReloadConfig — only patch once per session.
if not vim.api._statuscol_patched then
  vim.api._statuscol_patched = true
  local orig_eval_statusline = vim.api.nvim_eval_statusline
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.api.nvim_eval_statusline = function(str, opts)
    if not (opts and opts.use_statuscol_lnum) then
      return orig_eval_statusline(str, opts)
    end
    in_lno_probe = in_lno_probe + 1
    local ok, result = pcall(orig_eval_statusline, str, opts)
    in_lno_probe = in_lno_probe - 1
    if not ok then error(result, 0) end
    return result
  end
end

local function lnumfunc(args, segment)
  if in_lno_probe > 0 then
    -- Force the absolute-number branch of builtin.lnumfunc regardless of
    -- the real rnu/nu state -- relying on args.rnu being accurate here is
    -- what let stale/cached values leak relative (cursor-distance) numbers
    -- into pinned context/gutter lines instead of their true line number.
    local fake = vim.tbl_extend("force", {}, args)
    fake.relnum = 0
    fake.nu = true
    return builtin.lnumfunc(fake, segment)
  end
  return builtin.lnumfunc(args, segment)
end

require("statuscol").setup {
  relculright = true,
  segments = {
    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { lnumfunc, " " }, click = "v:lua.ScLa" },
    { text = { foldfunc, " " }, condition = { true, builtin.not_empty }, click = "v:lua.ScFa" },
  },
}
