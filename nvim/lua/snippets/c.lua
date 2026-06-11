local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- True when the format string contains a real format specifier (not %%).
-- Used to mirror UltiSnips' conditional transform: (?2:, :);)
local function has_fmt(args) return args[1][1]:find("%%[^%%]") ~= nil end

return {
  -- fprintf with %s[%d] + __FUNCTION__/__LINE__ prefix
  s({ trig = "fprd", dscr = "fprintf with func/line prefix" }, {
    t("fprintf("), i(1, "stderr"), t(', "%s[%d] '), i(2, "msg"),
    t('\\n", __FUNCTION__, __LINE__'),
    f(function(args) return has_fmt(args) and ", " or ");" end, { 2 }),
    i(3),
    f(function(args) return has_fmt(args) and ");" or "" end, { 2 }),
  }),

  s({ trig = "sw", dscr = "switch statement" }, {
    t("switch ( "), i(1), t({ " ){", "\t" }), i(0), t({ "", "}" }),
  }),

  s({ trig = "cs", dscr = "case branch" }, {
    t("case "), i(1), t({ ":", "\t" }), i(2), t({ "", "\t" }), i(3, "break;"),
    t({ "", "" }), i(0),
  }),

  s({ trig = "swd", dscr = "default branch" }, {
    t({ "default:", "\t" }), i(1), t({ "", "" }), i(0),
  }),

  -- printk with KERN_EMERG
  s({ trig = "prk", dscr = "printk KERN_EMERG" }, {
    t('printk(KERN_EMERG "'), i(1, "%s"), t('\\n"'),
    f(function(args) return has_fmt(args) and ", " or ");" end, { 1 }),
    i(2),
    f(function(args) return has_fmt(args) and ");" or "" end, { 1 }),
  }),

  -- printk with %s[%d] + __FUNCTION__/__LINE__ prefix
  s({ trig = "prkd", dscr = "printk with func/line prefix" }, {
    t('printk(KERN_EMERG "%s[%d] '), i(1, "%s"),
    t('\\n", __FUNCTION__, __LINE__'),
    f(function(args) return has_fmt(args) and ", " or ");" end, { 1 }),
    i(2),
    f(function(args) return has_fmt(args) and ");" or "" end, { 1 }),
  }),
}
