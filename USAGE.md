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
17. [User Commands](#user-commands)
18. [Tips & Workflows](#tips--workflows)

---

## General

| Key | Mode | Action |
|-----|------|--------|
| `;` | n/v | Enter command mode (same as `:`) |
| `<leader>ev` | n | Edit `init.lua` in a new tab |
| `<leader>sv` | n | Reload `init.lua` without restarting |
| `<leader>lc` | n | Change working directory to current file's folder |
| `<leader>ub` | n | Blink cursor to find its position |
| `<leader>cl` | n | Toggle cursor column highlight |
| `<leader>fm` | n | Toggle fold method: treesitter ↔ manual (freeze folds) |
| `<F12>` | n/i | Toggle spell check |

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
| `<leader>ft` | n | Buffer tags (ctags) |
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
| `H` | n/v | Jump to first non-blank character of line |
| `L` | n/v | Jump to last non-blank character of line |

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
| `<leader><CR>` | n | Clear search highlight |

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

### LSP Definitions & References (Glance)

| Key | Mode | Action |
|-----|------|--------|
| `<space>gd` | n | Peek definitions (Glance) |
| `<space>gr` | n | Peek references (Glance) |
| `<space>gi` | n | Peek implementations (Glance) |
| `<leader>K` | n | Show type definition in float |

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
| `<leader>tc` | Toggle treesitter context bar |
| `[C` | Jump up to current context (e.g. jump to function signature) |
| `:TSContextToggle` | Same as `<leader>tc` |

### Vista (symbol outline)

| Key | Action |
|-----|--------|
| `<space>t` | Toggle Vista symbol outline |

---

## LSP

| Key | Mode | Action |
|-----|------|--------|
| `<space>gd` | n | Peek definitions (Glance popup) |
| `<space>gr` | n | Peek references (Glance popup) |
| `<space>gi` | n | Peek implementations (Glance popup) |
| `<leader>K` | n | Hover type definition |
| Standard LSP keys apply — see `:help lsp-defaults` for `gd`, `K`, `<space>rn`, `<space>ca` |

### LSP Diagnostics

| Key | Action |
|-----|--------|
| `[d` / `]d` | Previous / next diagnostic |
| `<space>e` | Show diagnostic float |
| `<space>q` | Add diagnostics to location list |

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

> **Setup required:** Install `lldb` (C/C++) and/or `pip install debugpy` (Python) before use.

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

## File Explorer (nvim-tree)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>nn` | n | Toggle file explorer |
| `<leader>nf` | n | Reveal current file in explorer |

> Inside nvim-tree: `a` create · `d` delete · `r` rename · `x` cut · `c` copy · `p` paste · `R` refresh · `?` help

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

## User Commands

| Command | Action |
|---------|--------|
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
| `:Vista!!` | Toggle symbol outline (also `<space>t`) |
| `:MundoToggle` | Toggle visual undo tree (also `<space>u`) |
| `:CscopeFiles [dir...]` | Generate `cscope.files` from dirs (default: cwd) |
| `:CscopeFiles! [dir...]` | Append dirs to existing `cscope.files` (de-dup) |
| `:CscopeBuild [filelist]` | Build `cscope.out` from `cscope.files` |
| `:CscopeImport {list...}` | Merge external file lists into `cscope.files` |
| `:CscopeUnique [filelist]` | De-duplicate `cscope.files` |
| `:Lazy` | Open plugin manager UI |
| `:Lazy sync` | Update all plugins |
| `:Mason` | Open LSP/tool installer UI |
| `:DapContinue` | Start or continue debug session |
| `:DapTerminate` | Terminate debug session |

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

### Debug a Python script
```bash
pip install debugpy   # once per virtualenv
```
1. Set breakpoint: `<leader>db`
2. Start: `<leader>dc` → select Python file when prompted
3. Step: `<leader>do` (over) / `<leader>di` (into)
4. Inspect variables in the DAP UI scopes panel
5. End: `<leader>dx`

### Search word under cursor vs regex
- `,ak` — literal, safe for any C/C++ expression
- `,akr` — regex mode for patterns like `\bfunc_\w+\b`
- `:AckRegex pattern` — same regex mode from command line

### Switch colorscheme
Edit the last line of `nvim/init.lua`:
```lua
color_scheme.select_colorscheme("tokyonight")
-- options: everforest · gruvbox_material · sonokai · tokyonight
--          catppuccin · kanagawa · nightfox
```
