local builtin = require("statuscol.builtin")

-- only show fold level up to this level
local fold_level_limit = 3
local function foldfunc(args)
  local ok, ffi = pcall(require, "statuscol.ffidef")
  if not ok then return builtin.foldfunc(args) end
  local C = ffi.C
  local foldinfo = C.fold_info(args.wp, args.lnum)
  if foldinfo.level > fold_level_limit then
    return " "
  end
  return builtin.foldfunc(args)
end

require("statuscol").setup {
  relculright = false,
  segments = {
    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    { text = { foldfunc, " " }, condition = { true, builtin.not_empty }, click = "v:lua.ScFa" },
  },
}
