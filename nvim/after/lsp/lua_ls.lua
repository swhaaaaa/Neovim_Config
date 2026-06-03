-- settings for lua-language-server can be found on https://luals.github.io/wiki/settings/
return {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      hint = {
        enable = true,
      },
      workspace = {
        -- lazydev.nvim adds the Neovim runtime to the library automatically;
        -- checkThirdParty=false suppresses the "Do you need to configure?" prompt.
        checkThirdParty = false,
      },
      diagnostics = {
        -- Silence false-positive "undefined global vim" in Neovim config files.
        globals = { "vim" },
      },
    },
  },
}
