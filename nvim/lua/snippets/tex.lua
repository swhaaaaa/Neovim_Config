local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s({ trig = "use", dscr = "usepackage" }, {
    t("\\usepackage{"), i(1, "package"), t("}"),
  }),

  s({ trig = "eqa", dscr = "equation environment" }, {
    t("\\begin{equation}\\label{"), i(1), t({ "}", "\t" }), i(2),
    t({ "", "\\end{equation}" }),
  }),
}
