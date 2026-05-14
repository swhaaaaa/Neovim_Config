local api = vim.api

-- Format current buffer via conform.nvim (if available)
api.nvim_create_user_command("Format", function(args)
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format { bufnr = args.buf, lsp_fallback = true }
  else
    vim.lsp.buf.format { async = false }
  end
end, { desc = "Format current buffer" })

-- Show LSP info for current buffer
api.nvim_create_user_command("LspInfo2", function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.WARN)
    return
  end
  local names = vim.tbl_map(function(c) return c.name end, clients)
  vim.notify("LSP: " .. table.concat(names, ", "), vim.log.levels.INFO)
end, { desc = "Show active LSP clients" })

-- Reload nvim config
api.nvim_create_user_command("ReloadConfig", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload init.lua" })

-- ─── LSP restart helper (Neovim 0.11 compatible) ─────────────────────────────
-- :LspRestart was removed in Neovim 0.11. Use this instead.
local function lsp_restart()
  vim.schedule(function()
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      local bufs = vim.lsp.get_buffers_by_client_id(client.id)
      vim.lsp.stop_client(client.id, true)
      -- Re-enable for each buffer the client was attached to
      for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(buf) then
          vim.lsp.enable(client.name, { bufnr = buf })
        end
      end
    end
  end)
end

vim.api.nvim_create_user_command("LspRestart", lsp_restart,
  { desc = "Restart all LSP clients (Neovim 0.11 compatible)" })

-- ─── Meson build helpers ──────────────────────────────────────────────────────

-- Helper: run meson setup for a single package directory
-- pkgdir  = absolute path to the package (source root)
-- builddir = name of the build subdirectory inside pkgdir (default: "builddir")
local function meson_setup_one(pkgdir, builddir, on_done)
  builddir = builddir or "builddir"
  local cmd = string.format("meson setup %s", builddir)
  vim.notify(string.format("[%s] %s", vim.fn.fnamemodify(pkgdir, ":t"), cmd),
    vim.log.levels.INFO, { title = "Meson" })

  vim.fn.jobstart(cmd, {
    cwd = pkgdir,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify(
          string.format("[%s] meson setup failed (exit %d)", vim.fn.fnamemodify(pkgdir, ":t"), code),
          vim.log.levels.ERROR, { title = "Meson" })
        if on_done then on_done(false) end
        return
      end
      -- Symlink compile_commands.json at the package root
      local link   = pkgdir .. "/compile_commands.json"
      local target = builddir .. "/compile_commands.json"
      vim.fn.system(string.format("ln -sf %s %s", target, link))
      vim.notify(
        string.format("[%s] Done → compile_commands.json", vim.fn.fnamemodify(pkgdir, ":t")),
        vim.log.levels.INFO, { title = "Meson" })
      if on_done then on_done(true) end
    end,
  })
end

-- :MesonSetup [pkg1] [pkg2] ...
-- Run meson setup on one or more package directories.
--
-- Usage examples:
--   :MesonSetup                          → setup cwd (default builddir)
--   :MesonSetup sdbusplus                → setup ./sdbusplus
--   :MesonSetup sdbusplus phosphor-logging bmcweb
--                                        → setup all three in parallel
--
-- Each package gets its own builddir/ and compile_commands.json symlink.
-- After all setups complete, LSP is restarted once.
vim.api.nvim_create_user_command("MesonSetup", function(opts)
  local cwd  = vim.fn.getcwd()
  local args = vim.split(opts.args, "%s+", { trimempty = true })

  -- No args → operate on cwd
  if #args == 0 then
    meson_setup_one(cwd, "builddir", function(_)
      lsp_restart()
    end)
    return
  end

  -- Expand each arg — supports:
  --   sdbusplus                  → single dir relative to cwd
  --   ./packages/*               → glob: all subdirs of packages/
  --   /absolute/path/to/pkg      → absolute path
  local pkgdirs = {}
  for _, arg in ipairs(args) do
    -- Expand glob via vim.fn.glob (returns newline-separated matches)
    local expanded = vim.fn.glob(arg, false, true)  -- true = return list
    if #expanded == 0 then
      -- Not a glob or no matches — try as plain path
      local abs = vim.fn.fnamemodify(arg, ":p"):gsub("/$", "")
      if vim.fn.isdirectory(abs) == 1 then
        table.insert(pkgdirs, abs)
      else
        vim.notify("Not found or not a directory: " .. arg,
          vim.log.levels.WARN, { title = "Meson" })
      end
    else
      -- Filter glob results to directories only
      for _, match in ipairs(expanded) do
        local abs = vim.fn.fnamemodify(match, ":p"):gsub("/$", "")
        if vim.fn.isdirectory(abs) == 1 then
          table.insert(pkgdirs, abs)
        end
      end
    end
  end

  if #pkgdirs == 0 then
    vim.notify("No valid directories found.", vim.log.levels.ERROR, { title = "Meson" })
    return
  end

  vim.notify(string.format("Setting up %d package(s)...", #pkgdirs),
    vim.log.levels.INFO, { title = "Meson" })

  local total = #pkgdirs
  local done  = 0
  for _, pkgdir in ipairs(pkgdirs) do
    meson_setup_one(pkgdir, "builddir", function(_)
      done = done + 1
      if done == total then
        vim.notify("All packages set up. Restarting LSP...",
          vim.log.levels.INFO, { title = "Meson" })
        lsp_restart()
      end
    end)
  end
end, {
  nargs = "*",
  complete = "dir",
  desc = "meson setup [pkg1 pkg2 ./*] — supports globs, runs in parallel",
})

-- :MesonBuild [pkgdir]
-- Runs `meson compile -C builddir` in the given package dir (or cwd).
-- Shows a clear error if builddir does not exist — run :MesonSetup first.
vim.api.nvim_create_user_command("MesonBuild", function(opts)
  local cwd = vim.fn.getcwd()
  local pkgdir = opts.args ~= "" and vim.fn.fnamemodify(opts.args, ":p"):gsub("/$", "") or cwd

  if vim.fn.isdirectory(pkgdir) == 0 then
    vim.notify("Directory not found: " .. opts.args, vim.log.levels.ERROR, { title = "Meson" })
    return
  end

  local builddir = pkgdir .. "/builddir"
  if vim.fn.isdirectory(builddir) == 0 then
    vim.notify(
      string.format("[%s] builddir/ not found — run :MesonSetup first",
        vim.fn.fnamemodify(pkgdir, ":t")),
      vim.log.levels.ERROR, { title = "Meson" })
    return
  end

  local cmd = string.format("cd %s && meson compile -C builddir", vim.fn.shellescape(pkgdir))
  vim.notify(string.format("[%s] meson compile -C builddir",
    vim.fn.fnamemodify(pkgdir, ":t")), vim.log.levels.INFO, { title = "Meson" })
  vim.cmd("botright 15split | terminal " .. cmd)
end, {
  nargs = "?",
  complete = "dir",
  desc = "meson compile -C builddir [pkgdir] — builds in pkgdir or cwd",
})

-- :MesonLink [builddir]
-- (Re)create compile_commands.json symlink only — builddir must already exist.
-- Useful when builddir exists but the symlink is missing or pointing to the wrong place.
vim.api.nvim_create_user_command("MesonLink", function(opts)
  local builddir = opts.args ~= "" and opts.args or "builddir"
  local cwd  = vim.fn.getcwd()
  local src  = builddir .. "/compile_commands.json"
  local link = cwd .. "/compile_commands.json"
  local abs_src = cwd .. "/" .. src

  if vim.fn.filereadable(abs_src) == 0 then
    vim.notify(src .. " not found — run :MesonSetup first",
      vim.log.levels.ERROR, { title = "Meson" })
    return
  end

  vim.fn.system(string.format("ln -sf %s %s", src, link))
  vim.notify("Symlinked: compile_commands.json → " .. src,
    vim.log.levels.INFO, { title = "Meson" })
  lsp_restart()
end, {
  nargs = "?",
  complete = "dir",
  desc = "create compile_commands.json symlink from [builddir]",
})

-- Keymaps
vim.keymap.set("n", "<leader>ms", "<cmd>MesonSetup<CR>", { desc = "meson: setup cwd + link" })
vim.keymap.set("n", "<leader>mb", "<cmd>MesonBuild<CR>", { desc = "meson: build" })
vim.keymap.set("n", "<leader>ml", "<cmd>MesonLink<CR>",  { desc = "meson: link compile_commands.json" })

