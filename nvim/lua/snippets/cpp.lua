local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function has_fmt(args) return args[1][1]:find("%%[^%%]") ~= nil end

return {
  s({ trig = "bare", dscr = "barebone code template" }, {
    t({
      "#include <iostream>",
      "#include <vector>",
      "#include <string>",
      "#include <map>",
      "#include <unordered_map>",
      "#include <set>",
      "#include <unordered_set>",
      "#include <stack>",
      "#include <queue>",
      "#include <numeric>",
      "",
      "using std::cout;",
      "using std::endl;",
      "using std::vector;",
      "using std::string;",
      "using std::map;",
      "using std::unordered_map;",
      "using std::set;",
      "using std::unordered_set;",
      "using std::stack;",
      "using std::queue;",
      "using std::pair;",
      "using std::make_pair;",
      "",
      "",
      "",
      "int main()",
      "{",
      "\t",
    }),
    i(0),
    t({ "", "\treturn 0;", "}" }),
  }),

  s({ trig = "icd", dscr = "#include directive" }, {
    t("#include <"), i(1), t({ ">", "" }), i(0),
  }),

  s({ trig = "plist", dscr = "print vector" }, {
    t({
      "template <class T>",
      "void printList(const T& arr, const string& desc){",
      '\tstd::cout << desc << ": [";',
      "",
      "\tfor (auto it = arr.begin(); it != arr.end(); it++){",
      '\t\tstd::cout << *it << ((std::next(it) != arr.end()) ? ", " : "");',
      "\t}",
      '\tstd::cout << "]\\n";',
      "}",
    }),
  }),

  s({ trig = "pmat", dscr = "print list of list" }, {
    t({
      "template <class T>",
      "void printMat(const vector<vector<T>>& mat, const string& desc){",
      '\tcout << desc << ": " << endl;',
      "",
      "\tfor (auto it1 = mat.begin(); it1 != mat.end(); it1++){",
      "\t\tauto cur_vec = *it1;",
      '\t\tcout << "[";',
      "\t\tfor (auto it2 = cur_vec.begin(); it2 != cur_vec.end(); it2++){",
      '\t\t\tcout << *it2 << ((std::next(it2) != cur_vec.end()) ? ", " : "]\\n");',
      "\t\t}",
      "\t}",
      "}",
    }),
  }),

  s({ trig = "pqueue", dscr = "print queue" }, {
    t({
      "template <class T>",
      "void printQueue(T q){",
      "\twhile(!q.empty()){",
      '\t\tstd::cout << q.top() << " ";',
      "\t\tq.pop();",
      "\t}",
      "\tstd::cout << '\\n';",
      "}",
    }),
  }),

  s({ trig = "cout", dscr = "print a variable" }, {
    t('cout << "'), i(1), t(': " << '), i(2), t(" << endl;"),
  }),

  s({ trig = "random", dscr = "generate a random list" }, {
    t({
      "// Generate a random sequence of length len, in range(low, high) (inclusive).",
      "// need to #include<random>",
      "vector<int> genRandom(int low, int high, int len){",
      "\tstd::random_device rd;",
      "\tstd::mt19937 gen(rd());",
      "\tstd::uniform_int_distribution<int> distribution(low, high);",
      "",
      "\tvector<int> arr(len, 0);",
      "\tfor (int i = 0; i != len; ++i){",
      "\t\tarr[i] = distribution(gen);",
      "\t}",
      "",
      "\treturn arr;",
      "}",
    }),
  }),

  s({ trig = "incset",   dscr = "Use set"   }, { t({ "#include <set>",   "", "using std::set;" }) }),
  s({ trig = "incmap",   dscr = "Use map"   }, { t({ "#include <map>",   "", "using std::map;" }) }),
  s({ trig = "incqueue", dscr = "Use queue" }, { t({ "#include <queue>", "", "using std::queue;" }) }),
  s({ trig = "incstr",   dscr = "Use string"}, { t({ "#include <string>","", "using std::string;" }) }),
  s({ trig = "incvec",   dscr = "Use vector"}, { t({ "#include <vector>","", "using std::vector;" }) }),
  s({ trig = "incstack", dscr = "Use stack" }, { t({ "#include <stack>", "", "using std::stack;" }) }),

  s({ trig = "vec",   dscr = "std::vector"        }, { t("vector<"), i(1), t("> "), i(2, "vec") }),
  s({ trig = "map",   dscr = "std::map"           }, { t("map<"), i(1), t(", "), i(2), t("> "), i(3, "mymap") }),
  s({ trig = "umap",  dscr = "std::unordered_map" }, { t("unordered_map<"), i(1), t(", "), i(2), t("> "), i(3, "mymap") }),
  s({ trig = "set",   dscr = "std::set"           }, { t("set<"), i(1), t("> "), i(2, "myset") }),
  s({ trig = "uset",  dscr = "std::unordered_set" }, { t("unordered_set<"), i(1), t("> "), i(2, "myset") }),
  s({ trig = "queue", dscr = "std::queue"         }, { t("queue<"), i(1), t("> "), i(2, "q") }),
  s({ trig = "stack", dscr = "std::stack"         }, { t("stack<"), i(1), t("> "), i(2, "mystack") }),

  s({ trig = "fprd", dscr = "std::fprintf with func/line prefix" }, {
    t("std::fprintf("), i(1, "stderr"), t(', "%s[%d] '), i(2, "msg"),
    t('\\n", __FUNCTION__, __LINE__'),
    f(function(args) return has_fmt(args) and ", " or ");" end, { 2 }),
    i(3),
    f(function(args) return has_fmt(args) and ");" or "" end, { 2 }),
  }),

  s({ trig = "sol", dscr = "solution instance" }, {
    t("auto solution = Solution();"), t({ "", "" }), i(0),
  }),

  s({ trig = "for", dscr = "for loop" }, {
    t("for ("), i(1), t("; "), i(2), t("; "), i(3), t({ "){", "\t" }), i(4), t({ "", "}" }),
  }),

  s({ trig = "if", dscr = "if condition" }, {
    t("if ("), i(1), t({ "){", "\t" }), i(2), t({ "", "}" }), t({ "", "" }), i(0),
  }),

  s({ trig = "ifelse", dscr = "if else condition" }, {
    t("if ("), i(1), t({ "){", "\t" }), i(2), t({ "", "}else{", "", "}" }),
  }),
}
