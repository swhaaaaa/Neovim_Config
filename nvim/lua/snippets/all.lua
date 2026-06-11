local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- "(?<!\w)ltx" r  →  wordTrig=true (default) is equivalent
  s({ trig = "ltx", dscr = "LaTeX symbol" }, t("LaTeX")),
  s({ trig = "arw", dscr = "Right-pointed arrow" }, { t("--> "), i(1) }),
}
