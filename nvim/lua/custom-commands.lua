local api = vim.api

-- Format current buffer via conform.nvim (if available)
api.nvim_create_user_command("Format", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format { bufnr = vim.api.nvim_get_current_buf(), lsp_format = "fallback" }
  else
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
      vim.lsp.buf.format { async = false }
    else
      vim.notify("No LSP client attached", vim.log.levels.WARN, { title = "Format" })
    end
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
-- Clears Lua's require() cache for all local config modules so that
-- re-sourcing init.lua and re-requiring plugin configs picks up file changes.
api.nvim_create_user_command("ReloadConfig", function()
  -- Reset bytecode cache so edited files are re-compiled, not served stale.
  if vim.loader and vim.loader.reset then
    vim.loader.reset()
  end

  -- 1. Clear top-level modules re-required by init.lua
  for _, name in ipairs({
    "globals", "custom-autocmd", "custom-commands",
    "mappings", "diagnostic-conf", "colorschemes",
  }) do
    package.loaded[name] = nil
  end

  -- 2. Clear and re-require all config.* plugin config modules.
  -- Some plugins error if setup() is called twice; only clear their cache
  -- (they take effect on next restart) rather than re-requiring them now.
  local no_rerun = { ["config.snacks"] = true }
  local plugin_configs = {}
  for name in pairs(package.loaded) do
    if name:match("^config%.") then
      table.insert(plugin_configs, name)
    end
  end
  for _, name in ipairs(plugin_configs) do
    package.loaded[name] = nil
    if not no_rerun[name] then
      pcall(require, name)
    end
  end

  -- 3. Re-source init.lua to reload top-level modules
  vim.cmd("source $MYVIMRC")
  vim.notify("Config reloaded (" .. #plugin_configs .. " plugin configs)", vim.log.levels.INFO)
end, { desc = "Reload init.lua and all config modules" })

-- ─── LSP restart helper (Neovim 0.11 compatible) ─────────────────────────────
-- :LspRestart was removed in Neovim 0.11. Use this instead.
local function lsp_restart()
  vim.schedule(function()
    -- vim.lsp.enable(name) re-attaches to every buffer of matching filetype
    -- on its own (via doautoall), so no per-buffer bookkeeping is needed here.
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients()) do
      names[client.name] = true
      client:stop(true)
    end
    for name in pairs(names) do
      vim.lsp.enable(name)
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

  local job_id = vim.fn.jobstart(cmd, {
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
      local ln_out = vim.fn.system(
        string.format("ln -sf %s %s", vim.fn.shellescape(target), vim.fn.shellescape(link)))
      if vim.v.shell_error ~= 0 then
        vim.notify(string.format("[%s] symlink failed: %s", vim.fn.fnamemodify(pkgdir, ":t"), ln_out),
          vim.log.levels.ERROR, { title = "Meson" })
        if on_done then on_done(false) end
        return
      end
      vim.notify(
        string.format("[%s] Done → compile_commands.json", vim.fn.fnamemodify(pkgdir, ":t")),
        vim.log.levels.INFO, { title = "Meson" })
      if on_done then on_done(true) end
    end,
  })
  if job_id <= 0 then
    vim.notify(
      string.format("[%s] failed to start meson (is meson installed?)", vim.fn.fnamemodify(pkgdir, ":t")),
      vim.log.levels.ERROR, { title = "Meson" })
    if on_done then on_done(false) end
  end
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
    meson_setup_one(cwd, "builddir", function(ok)
      if ok then lsp_restart() end
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
      local before = #pkgdirs
      for _, match in ipairs(expanded) do
        local abs = vim.fn.fnamemodify(match, ":p"):gsub("/$", "")
        if vim.fn.isdirectory(abs) == 1 then
          table.insert(pkgdirs, abs)
        end
      end
      if #pkgdirs == before then
        vim.notify("Glob matched " .. #expanded .. " file(s) but no directories: " .. arg,
          vim.log.levels.WARN, { title = "Meson" })
      end
    end
  end

  if #pkgdirs == 0 then
    vim.notify("No valid directories found.", vim.log.levels.ERROR, { title = "Meson" })
    return
  end

  vim.notify(string.format("Setting up %d package(s)...", #pkgdirs),
    vim.log.levels.INFO, { title = "Meson" })

  local total    = #pkgdirs
  local done     = 0
  local failures = 0
  for _, pkgdir in ipairs(pkgdirs) do
    meson_setup_one(pkgdir, "builddir", function(ok)
      done = done + 1
      if not ok then failures = failures + 1 end
      if done == total then
        if failures == 0 then
          vim.notify("All packages set up. Restarting LSP...",
            vim.log.levels.INFO, { title = "Meson" })
        else
          vim.notify(string.format("%d/%d package(s) failed. Restarting LSP anyway...", failures, total),
            vim.log.levels.WARN, { title = "Meson" })
        end
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

  local ln_out = vim.fn.system(
    string.format("ln -sf %s %s", vim.fn.shellescape(src), vim.fn.shellescape(link)))
  if vim.v.shell_error ~= 0 then
    vim.notify("symlink failed: " .. ln_out, vim.log.levels.ERROR, { title = "Meson" })
    return
  end
  vim.notify("Symlinked: compile_commands.json → " .. src,
    vim.log.levels.INFO, { title = "Meson" })
  lsp_restart()
end, {
  nargs = "?",
  complete = "dir",
  desc = "create compile_commands.json symlink from [builddir]",
})

-- ─── GCC / G++ debug build helper ────────────────────────────────────────────
-- :GccDebug [output]
-- Compile the current C or C++ file with -g -O0 for DAP debugging.
-- Output binary defaults to <same-dir>/<stem>; override with an argument.
--   :GccDebug            → builds src/foo.c → src/foo
--   :GccDebug /tmp/foo   → builds into /tmp/foo
vim.api.nvim_create_user_command("GccDebug", function(opts)
  local src = vim.fn.expand("%:p")
  if src == "" then
    vim.notify("GccDebug: no file loaded", vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.filetype
  if ft ~= "c" and ft ~= "cpp" then
    vim.notify("GccDebug: C/C++ file required (current filetype: " .. ft .. ")",
      vim.log.levels.ERROR)
    return
  end

  local compiler = ft == "c" and "gcc" or "g++"
  if vim.fn.executable(compiler) == 0 then
    vim.notify("GccDebug: '" .. compiler .. "' not found on PATH",
      vim.log.levels.ERROR)
    return
  end

  local output = opts.args ~= ""
    and opts.args
    or (vim.fn.expand("%:p:h") .. "/" .. vim.fn.expand("%:t:r"))

  local cmd = string.format("%s -g -O0 -o %s %s",
    compiler, vim.fn.shellescape(output), vim.fn.shellescape(src))

  vim.notify(cmd, vim.log.levels.INFO, { title = "GccDebug" })
  vim.cmd("botright 8split | terminal " .. cmd)
end, {
  nargs = "?",
  complete = "file",
  desc = "compile current C/C++ file with -g -O0 for DAP debugging",
})

-- ─── OpenBMC / Yocto kernel LSP setup ───────────────────────────────────────
-- :KernelSetup [openbmc_build_root]
--
-- One-shot command to get clangd working on a Yocto-built Linux kernel:
--   1. Auto-discovers KSRC = tmp/work-shared/*/kernel-source/
--   2. Auto-discovers KBLD = tmp/work/*/linux-*/*/linux-*-standard-build/
--   3. Runs gen_compile_commands.py  →  KSRC/compile_commands.json
--   4. Writes KSRC/.clangd stripping GCC-only flags clangd can't parse
--   5. Restarts LSP
--
-- Usage:
--   :KernelSetup                                   (auto-detects from current buffer path)
--   :KernelSetup /path/to/build_ventura2_quanta    (explicit override)
-- Walk up from `startpath` until a directory containing tmp/work-shared/ is found
local function find_kernel_build_root(startpath)
  local path = startpath:gsub("/$", "")
  for _ = 1, 15 do
    if vim.fn.isdirectory(path .. "/tmp/work-shared") == 1 then
      return path
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then break end
    path = parent
  end
  return nil
end

vim.api.nvim_create_user_command("KernelSetup", function(opts)
  local buildroot

  if opts.args ~= "" then
    -- Explicit argument
    buildroot = vim.fn.fnamemodify(opts.args, ":p"):gsub("/$", "")
  else
    -- Auto-detect: try buffer path first, then cwd — walk up the tree either way
    local bufpath = vim.fn.expand("%:p")
    local startpath = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":h")) or vim.fn.getcwd()
    buildroot = find_kernel_build_root(startpath)
    if not buildroot then
      vim.notify("KernelSetup: cannot find a build root (no tmp/work-shared/ found above cwd).\n"
        .. "Run :KernelSetup /path/to/build_root explicitly.", vim.log.levels.ERROR)
      return
    end
  end

  if vim.fn.isdirectory(buildroot) == 0 then
    vim.notify("KernelSetup: not a directory: " .. buildroot, vim.log.levels.ERROR)
    return
  end

  -- Discover kernel source dir
  local ksrc_list = vim.fn.glob(buildroot .. "/tmp/work-shared/*/kernel-source", false, true)
  if #ksrc_list == 0 then
    vim.notify("KernelSetup: kernel source not found under\n  " .. buildroot .. "/tmp/work-shared/",
      vim.log.levels.ERROR)
    return
  end
  local ksrc = ksrc_list[1]

  -- Discover kernel build dir (contains .cmd files needed by gen_compile_commands.py)
  local kbld_list = vim.fn.glob(buildroot .. "/tmp/work/*/linux-*/*/linux-*-standard-build", false, true)
  if #kbld_list == 0 then
    vim.notify("KernelSetup: kernel build dir not found under\n  " .. buildroot .. "/tmp/work/",
      vim.log.levels.ERROR)
    return
  end
  local kbld = kbld_list[1]

  local gen_script = ksrc .. "/scripts/clang-tools/gen_compile_commands.py"
  if vim.fn.filereadable(gen_script) == 0 then
    vim.notify("KernelSetup: gen_compile_commands.py not found at\n  " .. gen_script,
      vim.log.levels.ERROR)
    return
  end

  local out_json = ksrc .. "/compile_commands.json"

  vim.notify(
    string.format("KernelSetup: generating compile_commands.json\n  src: %s\n  bld: %s", ksrc, kbld),
    vim.log.levels.INFO, { title = "KernelSetup" })

  vim.fn.jobstart({ "python3", gen_script, "-d", kbld, "-o", out_json }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("KernelSetup: gen_compile_commands.py failed (exit " .. code .. ")",
            vim.log.levels.ERROR, { title = "KernelSetup" })
          return
        end

        -- Write .clangd to strip flags that GCC supports but clangd/LLVM rejects
        local clangd_path = ksrc .. "/.clangd"
        local f = io.open(clangd_path, "w")
        if not f then
          vim.notify("KernelSetup: failed to write " .. clangd_path,
            vim.log.levels.ERROR, { title = "KernelSetup" })
          return
        end
        f:write(table.concat({
          "CompileFlags:",
          "  Remove:",
          "    - -mabi=aapcs-linux",
          "    - -fcanon-prefix-map",
          "    - -fno-var-tracking",
          "    - -femit-struct-debug-baseonly",
          "    - -fno-allow-store-data-races",
          "    - -fno-ipa-sra",
          "    - -mno-fdpic",
          "    - -fno-dwarf2-cfi-asm",
          "    - -mstack-protector-guard=tls",
          "    - -mstack-protector-guard-offset=*",
          "    - -fstrict-flex-arrays=*",
          "    - -Wa,-mno-warn-deprecated",
          "    - -fuse-ld=*",
          "",
        }, "\n"))
        f:close()

        vim.notify(
          string.format("KernelSetup done\n  %s\n  %s\nRestarting LSP...", out_json, clangd_path),
          vim.log.levels.INFO, { title = "KernelSetup" })
        lsp_restart()
      end)
    end,
  })
end, {
  nargs = "?",
  complete = "dir",
  desc = "Generate compile_commands.json + .clangd for OpenBMC/Yocto kernel, then restart LSP",
})

-- ─── OpenBMC / OE package LSP setup ─────────────────────────────────────────
-- :OEPkgSetup [package-name]
--
-- clangd already finds build/compile_commands.json automatically by searching
-- parent dirs.  The real problem is that bitbake injects GCC-only flags and
-- path-remapping flags that clangd/clang rejects, causing every file to fail
-- to compile.  This command writes a .clangd at the package source root that
-- strips those flags, then restarts LSP.  No rebuild, fully non-invasive.
--
-- Flags stripped:
--   -fcanon-prefix-map       GCC-only; clang doesn't know it
--   -flto=auto               clang accepts -flto but not the 'auto' value
--   -ffile-prefix-map=*      remaps source paths to /usr/src/debug/... which
--                            doesn't exist on the host, confusing clangd
--
-- Usage:
--   :OEPkgSetup sdbusplus    ← explicit package name
--   :OEPkgSetup              ← auto-detects package from current buffer path
vim.api.nvim_create_user_command("OEPkgSetup", function(opts)
  -- Find Yocto build root (walk up from buffer/cwd)
  local bufpath   = vim.fn.expand("%:p")
  local startpath = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":h")) or vim.fn.getcwd()
  local buildroot = find_kernel_build_root(startpath)
  if not buildroot then
    vim.notify(
      "OEPkgSetup: cannot find Yocto build root.\nRun from inside the build tree.",
      vim.log.levels.ERROR)
    return
  end

  -- Resolve package name (explicit arg or auto-detect from buffer path)
  local pkg
  if opts.args ~= "" then
    pkg = vim.trim(opts.args)
  else
    pkg = bufpath:match("/tmp/work/[^/]+/([^/]+)/")
    if not pkg then
      vim.notify(
        "OEPkgSetup: cannot detect package from buffer path.\n"
        .. "Usage: :OEPkgSetup <package-name>",
        vim.log.levels.ERROR)
      return
    end
  end

  -- Find the package work dir:  tmp/work/<arch>/<pkg>/<version>/
  local raw = vim.fn.glob(buildroot .. "/tmp/work/*/" .. pkg .. "/*", false, true)
  local workdirs = {}
  for _, p in ipairs(raw) do
    local clean = p:gsub("/$", "")
    if vim.fn.isdirectory(clean) == 1 then
      table.insert(workdirs, clean)
    end
  end
  if #workdirs == 0 then
    vim.notify(
      string.format("OEPkgSetup: package '%s' not found under\n  %s/tmp/work/", pkg, buildroot),
      vim.log.levels.ERROR, { title = "OEPkgSetup" })
    return
  end
  local workdir = workdirs[1]

  -- compile_commands.json is in build/ (written by meson/cmake during bitbake do_compile)
  local cc_json = workdir .. "/build/compile_commands.json"
  if vim.fn.filereadable(cc_json) == 0 then
    vim.notify(
      string.format("OEPkgSetup [%s]: compile_commands.json not found at\n  %s\n"
        .. "Build the package first:  bitbake %s", pkg, cc_json, pkg),
      vim.log.levels.ERROR, { title = "OEPkgSetup" })
    return
  end

  -- Derive the real source root from the first "file" entry in compile_commands.json.
  -- The "directory" field is the build dir; "file" is relative to it.
  -- Walking up from the resolved source file to find meson.build/CMakeLists.txt
  -- is far more reliable than find(1), which picks subproject build files.
  local cc_head  = vim.fn.system("head -6 " .. vim.fn.shellescape(cc_json))
  local build_dir = cc_head:match('"directory"%s*:%s*"([^"]+)"')
  local rel_file  = cc_head:match('"file"%s*:%s*"([^"]+)"')
  local srcroot
  if build_dir and rel_file then
    local abs_file = rel_file:sub(1, 1) == "/"
      and rel_file
      or vim.fn.system("realpath " .. vim.fn.shellescape(build_dir .. "/" .. rel_file)):gsub("\n$", "")
    local dir = vim.fn.fnamemodify(abs_file, ":h")
    for _ = 1, 10 do
      if vim.fn.filereadable(dir .. "/meson.build") == 1
        or vim.fn.filereadable(dir .. "/CMakeLists.txt") == 1 then
        srcroot = dir
        break
      end
      local parent = vim.fn.fnamemodify(dir, ":h")
      if parent == dir then break end
      dir = parent
    end
  end
  if not srcroot then
    vim.notify(
      string.format("OEPkgSetup [%s]: source root not found above\n  %s", pkg, workdir),
      vim.log.levels.ERROR, { title = "OEPkgSetup" })
    return
  end

  -- Write .clangd at the source root to strip flags clangd/clang cannot parse
  local clangd_path = srcroot .. "/.clangd"
  local f = io.open(clangd_path, "w")
  if not f then
    vim.notify("OEPkgSetup [" .. pkg .. "]: failed to write " .. clangd_path,
      vim.log.levels.ERROR, { title = "OEPkgSetup" })
    return
  end
  f:write(table.concat({
    "CompileFlags:",
    "  Remove:",
    "    - -fcanon-prefix-map",
    "    - -flto=auto",
    "    - -ffile-prefix-map=*",
    "",
  }, "\n"))
  f:close()

  vim.notify(
    string.format("OEPkgSetup [%s] done\n  src:    %s\n  .clangd written (strips GCC-only flags)\nRestarting LSP...",
      pkg, srcroot),
    vim.log.levels.INFO, { title = "OEPkgSetup" })
  lsp_restart()
end, {
  nargs = "?",
  desc = "Link bitbake compile_commands.json to source root for an OE/Yocto package",
})

-- Keymaps
vim.keymap.set("n", "<leader>ms", "<cmd>MesonSetup<CR>", { desc = "meson: setup cwd + link" })
vim.keymap.set("n", "<leader>mb", "<cmd>MesonBuild<CR>", { desc = "meson: build" })
vim.keymap.set("n", "<leader>ml", "<cmd>MesonLink<CR>",  { desc = "meson: link compile_commands.json" })
vim.keymap.set("n", "<leader>ks", "<cmd>KernelSetup<CR>", { desc = "kernel: gen compile_commands + .clangd (OpenBMC/Yocto)" })
vim.keymap.set("n", "<leader>kp", "<cmd>OEPkgSetup<CR>",  { desc = "OE pkg: link bitbake compile_commands.json" })

