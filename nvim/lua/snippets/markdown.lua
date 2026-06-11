local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
  -- regex trigger: (k1|kbd) r  →  regTrig = true
  s({ trig = "(k1|kbd)", regTrig = true, dscr = "HTML kbd tag" }, {
    t("<kbd>"), i(1, "KEY"), t("</kbd>"), i(0),
  }),

  s({ trig = "k2", dscr = "Two key strokes shortcut" }, {
    t("<kbd>"), i(1, "KEY"), t("</kbd> + <kbd>"), i(2, "KEY"), t("</kbd>"),
  }),

  s({ trig = "k3", dscr = "Three key strokes shortcut" }, {
    t("<kbd>"), i(1, "KEY"), t("</kbd> + <kbd>"), i(2, "KEY"),
    t("</kbd> + <kbd>"), i(3, "KEY"), t("</kbd>"),
  }),

  -- "h([1-6])" br  →  regTrig=true, snip.captures[1] gives the level digit.
  -- Replaces the gen_header post_jump approach from UltiSnips.
  s({ trig = "h([1-6])", regTrig = true, dscr = "Markdown header" }, {
    f(function(_, snip)
      return string.rep("#", tonumber(snip.captures[1]) or 1) .. " "
    end),
    i(1, "Section Name"),
    t({ "", "" }),
    i(0),
  }),

  -- !p datetime  →  vim.fn.strftime via function node
  s({ trig = "meta", dscr = "Markdown front matter (YAML format)" }, {
    t({ "---", 'title: "' }), i(1), t({ '"', "date: " }),
    f(function() return vim.fn.strftime("%Y-%m-%d %H:%M:%S%z") end),
    t({ "", "tags: [" }), i(2), t({ "]", "categories: [" }), i(3),
    t({ "]", "---", "" }),
    i(0),
  }),

  s({ trig = "more", dscr = "HTML more tag" }, t("<!--more-->")),

  s({ trig = "img", dscr = "Aligned image using HTML tag" }, {
    t({ '<p align="center">', '<img src="' }), i(1, "URL"),
    t('" width="'), i(2, "800"), t({ '">', "</p>", "" }),
    i(0),
  }),

  s({ trig = "font", dscr = "HTML font tag" }, {
    t('<font color="'), i(1, "blue"), t('">'), i(2, "TEXT"), t("</font>"),
  }),

  s({ trig = "link", dscr = "Markdown link" }, {
    t("["), i(1), t("]("), i(2), t(")"), i(0),
  }),

  s({ trig = "rlink", dscr = "Markdown ref link" }, {
    t("["), i(1, "link_text"), t("]["), i(2, "label"), t("]"),
  }),

  s({ trig = "detail", dscr = "Clickable details" }, {
    t({ "<details>", '<summary><font size="2" color="red">' }),
    i(1, "Click to show the code."),
    t({ "</font></summary>", "", "" }),
    i(2),
    t({ "", "</details>" }),
  }),

  s({ trig = "yh", dscr = "直角引号" }, { t("「"), i(1), t("」") }),

  s({ trig = "td", dscr = "tl;dr" }, { t("tl;dr: "), i(1) }),

  s({ trig = "info", dscr = "info box" }, {
    t({
      "<style type=\"text/css\">",
      "@import url('//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css');",
      "",
      ".info-msg {",
      "\tcolor: #059;",
      "\tbackground-color: #BEF;",
      "\tmargin: 5px 0;",
      "\tmargin-bottom: 20px;",
      "\tpadding: 10px;",
      "\tborder-radius: 5px 5px 5px 5px;",
      "\tborder: 2px solid transparent;",
      "\tborder-color: transparent;",
      "}",
      "</style>",
      "",
      "<div class=\"info-msg\">",
      "\t<i class=\"fa fa-info-circle\"> Info</i></br>",
      "\t",
    }),
    i(1, "info text"),
    t({ "", "</div>", "" }),
    i(0),
  }),

  s({ trig = "warn", dscr = "warning box" }, {
    t({
      "<style type=\"text/css\">",
      "@import url('//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css');",
      "",
      ".warning-msg {",
      "\tcolor: #9F6000;",
      "\tbackground-color: #FEEFB3;",
      "\tmargin: 5px 0;",
      "\tmargin-bottom: 20px;",
      "\tpadding: 10px;",
      "\tborder-radius: 5px 5px 5px 5px;",
      "\tborder: 2px solid transparent;",
      "\tborder-color: transparent;",
      "}",
      "</style>",
      "",
      "<div class=\"warning-msg\">",
      "\t<i class=\"fa fa-warning\"> Warning</i></br>",
      "\t",
    }),
    i(1, "warning text"),
    t({ "", "</div>", "" }),
    i(0),
  }),

  s({ trig = "error", dscr = "error box" }, {
    t({
      "<style type=\"text/css\">",
      "@import url('//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css');",
      "",
      ".error-msg {",
      "\tcolor: #D8000C;",
      "\tbackground-color: #FFBABA;",
      "\tmargin: 5px 0;",
      "\tmargin-bottom: 20px;",
      "\tpadding: 10px;",
      "\tborder-radius: 5px 5px 5px 5px;",
      "\tborder: 2px solid transparent;",
      "\tborder-color: transparent;",
      "}",
      "</style>",
      "",
      "<div class=\"error-msg\">",
      "\t<i class=\"fa fa-times-circle\"> Error</i></br>",
      "\t",
    }),
    i(1, "error text"),
    t({ "", "</div>", "" }),
    i(0),
  }),

  s({ trig = "success", dscr = "success box" }, {
    t({
      "<style type=\"text/css\">",
      "@import url('//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css');",
      "",
      ".success-msg {",
      "\tcolor: #270;",
      "\tbackground-color: #DFF2BF;",
      "\tmargin: 5px 0;",
      "\tmargin-bottom: 20px;",
      "\tpadding: 10px;",
      "\tborder-radius: 5px 5px 5px 5px;",
      "\tborder: 2px solid transparent;",
      "\tborder-color: transparent;",
      "}",
      "</style>",
      "",
      "<div class=\"success-msg\">",
      "\t<i class=\"fa fa-check\"></i>",
      "\t",
    }),
    i(1, "success text"),
    t({ "", "</div>", "" }),
    i(0),
  }),
}
