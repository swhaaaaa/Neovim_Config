local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
  -- `!v strftime(...)` → vim.fn.strftime via function node
  s({ trig = "head", dscr = "Python source file header" }, {
    t({ '"""', "Description: " }), i(1),
    t({ "", "Author: swhaaaaa (swhaaaaa@gmail.com)", "Created: " }),
    f(function() return vim.fn.strftime("%Y-%m-%d %H:%M:%S%z") end),
    t({ "", '"""', "" }),
    i(0),
  }),

  s({ trig = "print", dscr = "print value with f-string" }, {
    t('print(f"'), i(1, "label"), t(': {'), i(2, "var"), t('}")'),
    t({ "", "" }), i(0),
  }),

  s({ trig = "impa", dscr = "import FOO as BAR" }, {
    t("import "), i(1, "FOO"), t(" as "), i(2, "BAR"),
  }),

  s({ trig = "main", dscr = "main function boilerplate" }, {
    t({ "def main():", "\t" }), i(0),
    t({ "", "", "", 'if __name__ == "__main__":', "\tmain()" }),
  }),

  s({ trig = "sol", dscr = "solution instance" }, {
    t("solution = Solution()"),
  }),
}
