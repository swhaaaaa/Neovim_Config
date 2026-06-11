return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      -- Use clippy for on-save checks (stricter than cargo check).
      -- --no-deps keeps it fast by only linting the current crate.
      checkOnSave = {
        allFeatures = true,
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"]     = { "async_trait" },
          ["napi-derive"]     = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      inlayHints = {
        bindingModeHints      = { enable = false },
        chainingHints         = { enable = true },
        closingBraceHints     = { enable = true, minLines = 25 },
        lifetimeElisionHints  = { enable = "never" },
        parameterHints        = { enable = true },
        typeHints             = { enable = true },
      },
    },
  },
}
