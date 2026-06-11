local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s({ trig = "fun", dscr = "vim function" }, {
    t("function! "), i(1, "MyFunc"), t("("), i(2), t({ ") abort", "\t" }), i(3),
    t({ "", "endfunction", "" }),
    i(0),
  }),

  s({ trig = "aug", dscr = "vim augroup" }, {
    t("augroup "), i(1, "GROUP_NAME"),
    t({ "", "\tautocmd!", "\tautocmd " }), i(2, "EVENT"), t(" "), i(3, "PATTERN"), t(" "), i(4),
    t({ "", "augroup END", "" }),
    i(0),
  }),
}
