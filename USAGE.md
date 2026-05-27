# Neovim Config — Usage Guide

> **Leader key** = `,`  
> **Notation**: `<leader>` = `,` · `<space>` = Space · `<CR>` = Enter · `n/v/i/t` = mode

---

## Table of Contents
1. [General](#general)
2. [Files & Buffers](#files--buffers)
3. [Windows & Tabs](#windows--tabs)
4. [Editing](#editing)
5. [Search](#search)
6. [Navigation](#navigation)
7. [LSP](#lsp)
8. [Git](#git)
9. [Debug (DAP)](#debug-dap)
10. [File Explorer](#file-explorer)
11. [Folding](#folding)
12. [Snippets](#snippets)
13. [Surround](#surround)
14. [C/C++ Tools](#cc-tools)
15. [Spelling](#spelling)
16. [Terminal](#terminal)
17. [Notifications](#notifications)
18. [Meson Build](#meson-build)
19. [OpenBMC / Yocto Kernel LSP](#openbmc--yocto-kernel-lsp)
20. [User Commands](#user-commands)
21. [Tips & Workflows](#tips--workflows)

---

## General

| Key | Mode | Action |
|-----|------|--------|
| `;` | n/v | Enter command mode (same as `:`) |
| `<leader>ev` | n | Edit `init.lua` in a new tab |
| `<leader>sv` | n | Reload `init.lua` without restarting |
| `<leader>lc` | n | Change working directory to current file's folder |
| `<leader>ub` | n | Blink cursor to find its position |
| `<leader>uc` | n | Pick colorscheme interactively (fzf-lua) |
| `<leader>ud` | n | Toggle diagnostics on/off (global) |
| `<leader>uD` | n | Toggle diagnostic float balloon on/off |
| `<leader>cl` | n | Toggle cursor column highlight |
| `<leader>fm` | n | Toggle fold method: treesitter ↔ manual (freeze folds) |
| `<F12>` | n/i | Toggle spell check |
| `<leader>tf` | n | Toggle format on save (conform.nvim) |
| `,` then wait | n | which-key popup — press `,` and hold ~0.5s to see all keymaps grouped by prefix |

---

## Files & Buffers

### Fuzzy Finding (fzf-lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files in cwd |
| `<leader>fg` | n | Live grep in cwd |
| `<leader>fg` | v | Live grep with visual selection pre-filled |
| `<leader>fr` | n | Recent files (oldfiles) |
| `<leader>fb` | n | Open buffers |
| `<leader>fh` | n | Help tags |
| `<leader>ft` | n | Find TODO/FIXME/HACK/NOTE comments (todo-comments) |
| `<leader>fB` | n | Buffer tags — fuzzy jump to symbol in current buffer (requires ctags) |
| `<leader>fd` | n | Live grep in a specific folder (prompted) |
| `<leader>fD` | n | Find files in a specific folder (prompted) |
| `<leader>sd` | n/v | Grep in a specific folder (prompted) |

### Buffer Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>b` | n | New empty buffer |
| `gb` | n | Go to next buffer (`{count}gb` for Nth buffer) |
| `gB` | n | Go to previous buffer |
| `\d` | n | Delete current buffer (switch to previous first) |
| `\D` | n | Delete all other buffers |
| `\x` | n | Close quickfix and location list |
| `<leader>w` | n | Save buffer (`:update`) |
| `<leader>q` | n | Save and close window |
| `<leader>Q` | n | Force quit Neovim (`:qa!`) |
| `<leader>p` | n | Paste below current line (preserves cursor) |
| `<leader>P` | n | Paste above current line |
| `<leader>y` | n | Yank entire buffer |

---

## Windows & Tabs

| Key | Mode | Action |
|-----|------|--------|
| `<C-h/j/k/l>` | n | Switch to left/down/up/right window |
| `<C-↑>` | n | Increase window height (+2) |
| `<C-↓>` | n | Decrease window height (-2) |
| `<C-→>` | n | Increase window width (+2) |
| `<C-←>` | n | Decrease window width (-2) |
| `<leader>tn` | n | New tab |
| `<leader>tc` | n | Close tab |
| `<F6>` | n | Close tab |
| `<F7>` | n | Previous tab |
| `<F8>` | n | Next tab |
| `<leader>te` | n | Open file browser in current file's directory |

---

## Editing

### Text Manipulation

| Key | Mode | Action |
|-----|------|--------|
| `<A-j>` | n/v | Move line / selection down |
| `<A-k>` | n/v | Move line / selection up |
| `<A-h>` | v | Move selection left |
| `<A-l>` | v | Move selection right |
| `<A-h>` | n | Move character left (`x2hp`) |
| `<A-l>` | n | Move character right (`xp`) |
| `<space>o` | n | Insert blank line below (cursor stays) |
| `<space>O` | n | Insert blank line above (cursor stays) |
| `J` | n | Join lines (cursor stays) |
| `gJ` | n | Join lines without space (cursor stays) |
| `<leader><space>` | n | Strip trailing whitespace |
| `c` / `C` / `cc` | n | Change without polluting the yank register |
| `<` / `>` | v | Indent and stay in visual mode |
| `$` | v | Go to last non-blank character (not EOL) |

### Insert Mode Helpers

| Key | Mode | Action |
|-----|------|--------|
| `<C-A>` | i | Jump to beginning of line |
| `<C-E>` | i | Jump to end of line |
| `<C-h>` | i | Delete char left (`<BS>`) |
| `<C-l>` | i | Delete char right (`<Del>`) |
| `<C-w>` | i | Delete word left — Vim built-in |
| `<C-u>` | i | Delete to line start — Vim built-in |
| `<c-u>` | i | Uppercase word under cursor (custom) |
| `<c-t>` | i | Title-case word under cursor (custom) |
| `<A-;>` | i | Insert semicolon at end of line |
| `<C-j>` | i | UltiSnips expand / jump to next `$` stop |
| `<C-k>` | i | UltiSnips jump to previous `$` stop |
| `<C-A>` | c | Jump to beginning of command line |

### Yank Ring (yanky.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `p` / `P` | n/v | Put after / before (tracked by yanky) |
| `[y` | n | Cycle to previous yank entry |
| `]y` | n | Cycle to next yank entry |
| `:YankyRingHistory` | — | Browse full yank history |

---

## Search

### In-file Search (hlslens)

| Key | Mode | Action |
|-----|------|--------|
| `n` / `N` | n | Next / previous match with count overlay |
| `*` / `#` | n | Search word under cursor forward / backward |

### Hop (in-buffer jump)

| Key | Mode | Action |
|-----|------|--------|
| `f` | n/v/o | 2-character hop — jump anywhere on screen |

### Ack (project-wide search)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `<leader>ak` | n | Search word under cursor (literal, safe for C/C++) |
| `<leader>ak` | v | Search visual selection (literal) |
| `<leader>akk` | n | Open `:Ack! ""` prompt — type literal pattern |
| `<leader>akr` | n | Open `:AckRegex ""` prompt — type regex pattern |
| `<leader>akc` | n | Clear Ack match highlights |
| `:AckRegex {pat}` | — | Search with regex (use for `*`, `\d`, `(` etc.) |

> Default backend is ripgrep with `--fixed-strings` so C/C++ expressions like `func(a, b)` work without escaping. Use `<leader>akr` / `:AckRegex` when you need real regex.

### Grug-Far (project-wide find & replace)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>rp` | n | Open grug-far replace panel |
| `<leader>rp` | v | Open panel with visual selection |
| `<leader>rw` | n | Open panel pre-filled with word under cursor |

> Inside the panel: type search/replace, then `<CR>` to preview, `<leader>r` to replace all.

---

## Navigation

### vim-illuminate (auto word highlight)

| Key | Mode | Action |
|-----|------|--------|
| `]r` | n | Jump to next occurrence of word under cursor |
| `[r` | n | Jump to previous occurrence |

> Automatically highlights all occurrences of the word under cursor using LSP → treesitter → regex (in priority order). Only activates when there are 2+ occurrences.

### vim-mark (manual multi-word highlight)

Like the classic `mark.vim` — manually mark words you want to track while reading source code. Each word gets a different color.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>mk` | n | Toggle highlight word under cursor |
| `<leader>mk` | v | Toggle highlight visual selection |
| `<leader>mK` | n | Clear all marks |
| `{N}<leader>mk` | n | Mark with specific color N (1-6) |

> Supports 6 simultaneous highlight colors. Use `*` / `#` to search within marked words.

### LSP Definitions & References (Glance)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ld` | n | Peek definitions (Glance) |
| `<leader>lr` | n | Peek references (Glance) |
| `<leader>li` | n | Peek implementations (Glance) |

### Cscope (C/C++ symbol navigation)

> Set `prefix = "<leader>c"` in `lua/config/cscope.lua` to enable these.

| Key | Action |
|-----|--------|
| `<prefix>s` | Find all references to symbol |
| `<prefix>g` | Find global definition |
| `<prefix>c` | Find all callers of function |
| `<prefix>t` | Find text string |
| `<prefix>e` | Egrep search |
| `<prefix>f` | Open file under cursor |
| `<prefix>i` | Find files including this file |
| `<prefix>d` | Find functions called by function |
| `<prefix>a` | Find where symbol is assigned |
| `<prefix>b` | Build cscope database |
| `Ctrl-]` | `:Cstag` jump to tag under cursor |

**Cscope user commands:**

| Command | Action |
|---------|--------|
| `:CscopeFiles [dir...]` | Generate `cscope.files` from dirs (default: cwd) |
| `:CscopeFiles! [dir...]` | Append dirs to existing `cscope.files` (de-dup) |
| `:CscopeFilesAdd [dir...]` | Same as `!` form |
| `:CscopeBuild [filelist]` | Build `cscope.out` from `cscope.files` |
| `:CscopeImport {list...}` | Merge external file lists into `cscope.files` |
| `:CscopeUnique [filelist]` | De-duplicate `cscope.files` |

### Undo Tree

| Key | Action |
|-----|--------|
| `<space>u` | Toggle Mundo undo tree |

### Treesitter Context

| Key / Command | Action |
|---------------|--------|
| `<leader>ux` | Toggle treesitter context bar on/off |
| `[C` | Jump up to current context (e.g. jump to function signature) |

### Aerial (symbol outline — LSP/treesitter)

| Key | Action |
|-----|--------|
| `<leader>ao` | Toggle aerial symbol outline |

> aerial.nvim uses LSP and treesitter — no ctags required. Works in any file with an LSP server or treesitter parser attached.

---

## LSP

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ld` | n | Peek definitions (Glance popup) |
| `<leader>lr` | n | Peek references (Glance popup) |
| `<leader>li` | n | Peek implementations (Glance popup) |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n | Code action |
| `<leader>wa` | n | Add workspace folder |
| `<leader>wr` | n | Remove workspace folder |
| `<leader>wl` | n | List workspace folders |
| `gd` | n | Go to definition (location list if multiple) |
| `K` | n | Hover documentation |
| `<leader>sh` | n | Signature help (moved from `<C-k>` — reserved for window navigation) |
| `<C-]>` | n | Go to definition (direct) |

### LSP Diagnostics

| Key | Action |
|-----|--------|
| `[d` / `]d` | Previous / next diagnostic |
| `<space>e` | Show diagnostic float |
| `<space>q` | Add diagnostics to location list |
| `<space>qb` | Add current buffer diagnostics to quickfix |
| `<space>qw` | Add all open files' diagnostics to quickfix |

> Diagnostic virtual lines appear inline beneath the cursor line only. A float with full detail opens automatically on `CursorHold` when the cursor sits on a diagnostic.

---

## Git

### Fugitive (`,gs`)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gs` | n | Open Fugitive status (`:Git`) |
| `<leader>gw` | n | Stage current file (`:Gwrite`) |
| `<leader>gc` | n | Commit staged (`:Git commit`) |
| `<leader>gpl` | n | Pull (`:Git pull`) |
| `<leader>gpu` | n | Push in terminal split |
| `<leader>gb` | v | Blame selected lines |
| `<leader>gd` | n | Diff split current file |
| `<leader>ge` | n | Edit file at HEAD |
| `<leader>gf` | n | `:Git fetch ` (prompt for remote) |
| `<leader>gbn` | n | Create new branch (prompted) |
| `<leader>gbd` | n | Delete branch (prompt for name) |

> Inside Fugitive status: `s` stage · `u` unstage · `=` toggle diff · `cc` commit · `q` close

### Neogit (`,gg`)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gg` | n | Open Neogit status |
| `<leader>ggc` | n | Commit popup |
| `<leader>ggp` | n | Push popup |
| `<leader>ggP` | n | Pull popup |
| `<leader>ggr` | n | Rebase popup |
| `<leader>ggl` | n | Log popup |
| `<leader>ggA` | n | Amend last commit (with edit) |
| `<leader>gga` | n | Amend last commit (no edit) |
| `<leader>ggR` | n | Reset file to HEAD |

> Inside Neogit: `s` stage · `S` stage all · `u` unstage · `cc` commit · `P p` push · `g?` help

### Gitsigns

| Key | Mode | Action |
|-----|------|--------|
| `]c` / `[c` | n | Next / previous hunk |
| `<leader>hp` | n | Preview hunk in float |
| `<leader>hb` | n | Blame current line |

### DiffView

| Command | Action |
|---------|--------|
| `:DiffviewOpen` | Open full project diff |
| `:DiffviewClose` | Close |
| `:DiffviewFileHistory %` | History for current file |

---

## Debug (DAP)

> **Setup required:** Install `codelldb` (preferred) or `lldb` (fallback) for C/C++, and `debugpy` for Python.
> - C/C++: `:MasonInstall codelldb` (preferred)  or  `sudo apt install lldb` (fallback — `install.sh` handles this)
> - Python: `sudo apt install python3-debugpy` (system)  or  `pip install debugpy` (per virtualenv) — `install.sh` handles this

| Key | Mode | Action |
|-----|------|--------|
| `<leader>dc` | n | Continue / start session |
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Conditional breakpoint (prompted) |
| `<leader>dL` | n | Log point (prompted) |
| `<leader>do` | n | Step over |
| `<leader>di` | n | Step into |
| `<leader>dO` | n | Step out |
| `<leader>dr` | n | Open REPL |
| `<leader>dl` | n | Re-run last debug session |
| `<leader>dx` | n | Terminate session |
| `<leader>du` | n | Toggle DAP UI (auto-opens with session) |

> The DAP UI opens automatically when a session starts, showing scopes, breakpoints, stacks, watches (left panel) and REPL/console (bottom panel).

---

## Session (persistence.nvim)

Sessions are saved automatically per working directory when you quit Neovim. On next launch, restore with `,ss`.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ss` | n | Restore session for current working directory |
| `<leader>sl` | n | Restore last session (any directory) |
| `<leader>sq` | n | Stop persistence — don't save session on exit |

> Session files are stored in `~/.local/state/nvim/sessions/`.

---

## Terminal (toggleterm.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tt` | n | Toggle floating terminal |

> Inside the terminal: press `<Esc><Esc>` to exit terminal mode and return to normal mode. Press `<leader>tt` again to hide the terminal (state is preserved).

---

## Task Runner (overseer.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ot` | n | Toggle task list panel |
| `<leader>or` | n | Run a task template (picker) |
| `<leader>oR` | n | Run a shell command as a task (`OverseerShell`) |

> Inside the task list panel: `<CR>` run action, `q` close, `<C-l>` / `<C-h>` increase/decrease detail.

---

## File Explorer

### NERDTree (sidebar tree)

| Key | Action |
|-----|--------|
| `<leader>nn` | Toggle NERDTree sidebar |
| `<leader>nf` | Reveal current file (works outside current root) |
| `<leader>nF` | Focus NERDTree window |

> Inside NERDTree: `o` open · `i` open split · `s` open vsplit · `t` open tab · `m` file menu (rename/delete/create) · `I` toggle hidden · `R` refresh · `?` help

### oil.nvim (buffer-style navigator)

| Key | Action |
|-----|--------|
| `-` | Open current file's directory as a buffer |
| `<leader>-` | Same, in a floating window |

> Inside oil buffer: edit like a normal buffer — delete line = delete file, add line = create file, rename line = rename file. Press `<CR>` to open, `-` to go up, `g.` toggle hidden, `q` close.

---

## Folding (nvim-ufo + treesitter)

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds except kinds |
| `za` / `zo` / `zc` | Toggle / open / close fold |
| `<leader>fm` | Toggle fold method: treesitter expr ↔ manual |

> Use `<leader>fm` to switch to `manual` after opening folds you want to keep — prevents treesitter from re-closing them on edits. Press `<leader>fm` again to re-enable treesitter folding.

---

## Snippets

Two snippet engines are available:

| Engine | Trigger | Files |
|--------|---------|-------|
| **LuaSnip** | Tab (via nvim-cmp) | VSCode-style JSON (`friendly-snippets`) |
| **UltiSnips** | `<C-j>` expand · `<C-j>/<C-k>` jump | `my_snippets/*.snippets` |

> Add custom snippets in `nvim/my_snippets/` using UltiSnips `.snippets` format.

---

## Surround (mini.surround)

> Works with pairs: `()` `[]` `{}` `""` `''` ` `` ` `<>` and custom

| Key | Action | Example |
|-----|--------|---------|
| `sa{motion}{char}` | Add surround | `saiw"` → `"word"` |
| `sd{char}` | Delete surround | `sd"` → `word` |
| `sr{old}{new}` | Replace surround | `sr"'` → `'word'` |
| `sf` / `sF` | Find next / previous surrounding | — |
| `sh` | Highlight surrounding | — |

---

## C/C++ Tools

### Header / Source Toggle (clangd)

| Key | Action |
|-----|--------|
| `<leader>as` | Switch between `.h` and `.c`/`.cpp` (LSP-aware) |

### clangd Extensions

| Key / Command | Action |
|---------------|--------|
| `<leader>ih` | Toggle inlay hints (parameter names/types shown inline) |
| `<leader>si` | Show symbol info (type, canonical declaration) |
| `<leader>at` | View AST for node under cursor |
| `<leader>mu` | Show clangd memory usage |

### Force Syntax Override

| Key | Action |
|-----|--------|
| `<leader>1` | Force C syntax |
| `<leader>2` | Force Python syntax |
| `<leader>3` | Force JavaScript filetype |
| `<leader>5` | Re-sync syntax from start |

---

## Spelling

| Key | Mode | Action |
|-----|------|--------|
| `<F12>` | n/i | Toggle spell check |
| `]s` / `[s` | n | Next / previous misspelling |
| `zg` | n | Add word to spell file |
| `z=` | n | Suggest corrections |

---

## Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tt` | n | Open terminal in 15-line bottom split |
| `<Esc>` | t | Exit terminal mode (back to normal) |

---

## Notifications

Notifications are handled by **snacks.nvim** (replaces nvim-notify). All `vim.notify()` calls throughout the config use it automatically.

| Command | Action |
|---------|--------|
| `<leader>un` | Browse all past notifications in a scrollable popup |

> Notifications stack from the **bottom-right** upward. Style: `fancy` (icon + title bar). Timeout: 1500 ms.
>
> `vim.ui.input()` is also handled by snacks — LSP rename prompts and other input dialogs appear as a floating input box instead of the command line.

---

## Trouble (Diagnostics & Quickfix UI)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `<leader>xx` | n | Toggle project-wide diagnostics |
| `<leader>xb` | n | Toggle buffer diagnostics |
| `<leader>xl` | n | Toggle location list |
| `<leader>xq` | n | Toggle quickfix list |
| `<leader>xs` | n | Toggle symbols list |
| `:Trouble diagnostics` | — | Project-wide LSP errors/warnings |
| `:Trouble lsp` | — | LSP references, definitions, implementations |
| `:Trouble qflist` | — | Quickfix list in Trouble UI |

---

## Quickfix

| Key | Mode | Action |
|-----|------|--------|
| `<leader>co` | n | Open quickfix list |
| `<leader>cc` | n | Close quickfix list |
| `]q` | n | Next quickfix item |
| `[q` | n | Previous quickfix item |
| `]Q` | n | Last quickfix item |
| `[Q` | n | First quickfix item |
| `\x` | n | Close quickfix and location list |

---

## Meson Build

| Key / Command | Action |
|---------------|--------|
| `<leader>ms` | `:MesonSetup` — setup cwd + create `compile_commands.json` symlink |
| `<leader>mb` | `:MesonBuild` — compile in a terminal split |
| `<leader>ml` | `:MesonLink` — (re)create symlink only (builddir already exists) |

**Usage examples:**
```
:MesonSetup                               → setup current directory
:MesonSetup sdbusplus                     → setup ./sdbusplus only
:MesonSetup sdbusplus phosphor-logging    → setup both in parallel
:MesonSetup ./*                           → setup ALL subdirs in cwd
:MesonSetup ./packages/*                  → setup all subdirs of packages/
:MesonSetup sdbusplus phosphor-logging bmcweb phosphor-host-ipmid
                                          → setup all four in parallel
```

All setups run in parallel. Each package gets its own `builddir/` and `compile_commands.json` symlink. LSP restarts once after all packages complete.

**Typical workflow for new OpenBMC packages:**
```
,lc                                         ← cd to packages parent folder
:MesonSetup sdbusplus phosphor-logging      ← setup both packages
:LspInfo2                                   ← verify clangd attached
```

---

## OpenBMC / Yocto Kernel LSP

`:KernelSetup` automates the full process of enabling clangd on a Yocto-built Linux kernel.

| Key / Command | Action |
|---------------|--------|
| `<leader>ks` | `:KernelSetup` — generate `compile_commands.json` + `.clangd`, restart LSP |
| `:KernelSetup [build_root]` | Same — auto-detects build root by walking up from current buffer/cwd |

**What it does automatically:**
1. Finds `tmp/work-shared/*/kernel-source/` → kernel source root (`KSRC`)
2. Finds `tmp/work/*/linux-*/*/linux-*-standard-build/` → kernel build dir (`KBLD`)
3. Runs `gen_compile_commands.py -d KBLD -o KSRC/compile_commands.json`
4. Writes `KSRC/.clangd` to strip GCC-only flags that clangd cannot parse
5. Restarts LSP

**Usage:**
```
:KernelSetup                                   ← auto-detects build root from current buffer path
:KernelSetup /path/to/build_ventura2_quanta    ← explicit override
```

**Typical workflow:**
```
→ open any file under .../build_ventura2_quanta/tmp/work-shared/.../kernel-source/
→ :KernelSetup  (no argument — build root is detected automatically)
→ wait for "KernelSetup done" notification
→ clangd attaches — gd, K, references all work
```

> clangd needs `compile_commands.json` at the project root to understand cross-compilation flags. Re-run `:KernelSetup` if the kernel is rebuilt (Yocto may regenerate the build dir).

---

## User Commands

| Command | Action |
|---------|--------|
| `:lua Snacks.notifier.show_history()` | Browse past notifications (also `<leader>un`) |
| `:Format` | Format current buffer (conform.nvim with LSP fallback) |
| `:LspInfo2` | Show active LSP clients for current buffer |
| `:ReloadConfig` | Reload `init.lua` without restarting Neovim |
| `:AckRegex {pat}` | Search with regex via ack.vim (bypasses `--fixed-strings`) |
| `:GrugFar` | Open project-wide find & replace panel |
| `:TodoFzfLua` | List all TODO/FIXME/HACK/NOTE comments via fzf-lua |
| `:TodoQuickFix` | Load all TODO comments into quickfix list |
| `:DiffviewOpen` | Open full project diff tree |
| `:Obsession` | Start/toggle session recording (auto-saves on exit) |
| `:Obsession {file}` | Start recording to a specific session file |
| `:AerialToggle` | Toggle symbol outline (also `<leader>ao`) |
| `:MundoToggle` | Toggle visual undo tree (also `<space>u`) |
| `:CscopeFiles [dir...]` | Generate `cscope.files` from dirs (default: cwd) |
| `:CscopeFiles! [dir...]` | Append dirs to existing `cscope.files` (de-dup) |
| `:CscopeBuild [filelist]` | Build `cscope.out` from `cscope.files` |
| `:CscopeImport {list...}` | Merge external file lists into `cscope.files` |
| `:CscopeUnique [filelist]` | De-duplicate `cscope.files` |
| `:Lazy` | Open plugin manager UI |
| `:Lazy sync` | Update all plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Mason` | Open LSP/tool installer UI |
| `:GccDebug [output]` | Compile current C/C++ file with `-g -O0` for DAP (output defaults to same dir/name as source) |
| `:DapContinue` | Start or continue debug session |
| `:DapTerminate` | Terminate debug session |
| `:MesonSetup [pkg1 pkg2 ...]` | `meson setup` on one or more package dirs in parallel + symlink `compile_commands.json` |
| `:MesonBuild [pkgdir]` | `meson compile -C builddir` in pkgdir or cwd (errors if builddir missing) |
| `:MesonLink [dir]` | Only (re)create `compile_commands.json` symlink without re-running setup |
| `:KernelSetup [build_root]` | Generate `compile_commands.json` + `.clangd` for OpenBMC/Yocto kernel, then restart LSP |
| `:LspRestart` | Restart LSP clients for current buffer |

---

## Tips & Workflows

### Search for a C/C++ function call with parentheses
Use `,ak` in normal mode — the literal search handles `(`, `,` and spaces safely:
```
position cursor on:  spi_gpio_txrx_word_mode0
press:               ,ak
```
Or use `,akk` and type the full expression: `spi_gpio_txrx_word_mode0(spi, n`

### Replace across the project
1. `,rp` → opens grug-far
2. Type search term, Tab to replace field, type replacement
3. `:w` or the confirm action to apply

### Stage and commit with Fugitive
1. `,gs` → opens Fugitive status
2. Move cursor to file → `s` to stage (or `S` to stage all)
3. `cc` → opens commit message buffer
4. Type message → `,w` to save and commit
5. `,gpu` to push

### Freeze folds before editing
When treesitter re-folds while you type:
1. Open the folds you want with `zR` or `zo`
2. Press `,fm` → switches to `manual` mode (folds are frozen)
3. Edit freely
4. Press `,fm` again to re-enable treesitter folding

### Debug a C/C++ file
1. Open the source file in Neovim
2. `:GccDebug` — compiles with `-g -O0`; binary lands next to the source file
3. Set breakpoint: `<leader>db`
4. Start: `<leader>dc` → select **Launch executable** → Tab-complete to the binary
5. Step: `<leader>do` (over) / `<leader>di` (into)
6. Inspect variables in the DAP UI Scopes panel
7. End: `<leader>dx`

### Debug a Python script
```bash
sudo apt install python3-debugpy   # system-wide (Ubuntu)
# or: pip install debugpy          # per virtualenv
```
1. Set breakpoint: `<leader>db`
2. Start: `<leader>dc` → select **file** when prompted
3. Step: `<leader>do` (over) / `<leader>di` (into)
4. Inspect variables in the DAP UI scopes panel
5. End: `<leader>dx`

### Search word under cursor vs regex
- `,ak` — literal, safe for any C/C++ expression
- `,akr` — regex mode for patterns like `\bfunc_\w+\b`
- `:AckRegex pattern` — same regex mode from command line

### Switch colorscheme
Press `<leader>uc` to open an interactive fzf-lua picker over all 7 schemes. The change takes effect immediately.

To set a permanent default, edit the last line of `nvim/init.lua`:
```lua
color_scheme.select_colorscheme("tokyonight")
-- options: everforest · gruvbox_material · sonokai · tokyonight
--          catppuccin · kanagawa · nightfox
```
