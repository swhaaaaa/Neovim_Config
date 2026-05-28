# Neovim Enhanced Config

A modern Neovim configuration built on **Lazy.nvim** with LSP, Treesitter,
fuzzy finding, git integration, Markdown editing/preview, and more.
Evolved from a classic Vim setup.

---

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Neovim | >= 0.11 | Required (`smoothscroll`, `virtual_lines` need 0.10+) |
| git | any | Plugin manager & git plugins |
| curl | any | Downloads |
| node + npm | any | Markdown preview, LSP servers |
| A [Nerd Font](https://www.nerdfonts.com/) | any | Icons in UI |

**Optional — required for specific features:**

| Tool | Purpose |
|------|---------|
| `ripgrep` (`rg`) | fzf-lua live grep, grug-far, ack.vim backend (preferred) |
| `ack` / `ack-grep` | ack.vim search backend (fallback when rg unavailable) |
| `fd` / `fdfind` | fzf-lua file listing |
| `ctags` | cscope |
| `cscope` | C/C++ symbol navigation |
| `clangd` | C/C++ LSP |
| `lldb-dap` or `lldb-vscode` | C/C++ debugger (DAP fallback) |
| `codelldb` (`:MasonInstall codelldb`) | C/C++ debugger (DAP preferred — better struct pretty-print) |
| `debugpy` | Python debugger (DAP) — `sudo apt install python3-debugpy` or `pip install debugpy` |

---

## Installation

```bash
git clone <repo-url> nvim-config   # or unzip the archive
cd nvim-config                     # scripts are now in the top-level folder

bash build_nvim.sh   # optional: build latest Neovim from source
bash install.sh      # installs tools, then links nvim/ → ~/.config/nvim
```

The installer will automatically:
1. Check / install **Neovim** >= 0.11 if missing
2. Install required tools: `git`, `curl`
3. Install recommended tools: `ripgrep`, `fzf`, `ctags`, `cscope`, `node`, `npm`
4. Install formatters: `stylua` (via cargo), `ruff` (via pip), `prettier` (via npm)
5. Install debug adapters: `lldb` for C/C++ (prompted); `debugpy` for Python (prompted); note `:MasonInstall codelldb` for preferred C/C++ adapter
6. Backup your existing config, then symlink or copy the new one
7. Fix `ulimit` open-file limit if too low (writes to `~/.bashrc`)

Supported package managers: `apt` · `dnf` · `pacman` · `brew`

On first launch, **Lazy.nvim** auto-installs all plugins. Then run:
```
:TSInstall!
```
to install Treesitter parsers.

---

## Plugin Overview

### Completion & Snippets
| Plugin | Role |
|--------|------|
| `nvim-cmp` | Completion engine |
| `LuaSnip` | Snippet engine (VSCode + custom snippets) |
| `UltiSnips` | UltiSnips `.snippets` file support |
| `friendly-snippets` | Pre-built snippet collection |
| `nvim-autopairs` | Auto-close brackets/quotes |

### LSP
| Plugin | Role |
|--------|------|
| `nvim-lspconfig` | LSP client configuration |
| `mason.nvim` | LSP/linter/formatter binary manager |
| `conform.nvim` | Formatter (stylua, ruff, prettier) |
| `fidget.nvim` | LSP progress indicator |
| `nvim-lightbulb` | Code action indicator (`💡`) |
| `glance.nvim` | LSP definition/references floating preview |
| `lazydev.nvim` | Lua API completion for config editing |

### Treesitter
| Plugin | Role |
|--------|------|
| `nvim-treesitter` | Syntax highlighting & folding |
| `nvim-treesitter-context` | Shows current function/block at top while scrolling |
| `mini.ai` | Textobjects (`af`, `if`, `ac`, `ic`, `aa`, `ia`) |
| `mini.surround` | Add/delete/replace surrounding pairs (`sa`, `sd`, `sr`) |

### Markdown
| Plugin | Role |
|--------|------|
| `vim-markdown` | Editing: TOC, list continuation, header jump, table format |
| `tabular` | Table & text alignment (`:Tabularize`) |
| `markdown-preview.nvim` | Live browser preview synced with cursor |
| `render-markdown.nvim` | In-editor rendering (conceals syntax, draws tables) |

### UI
| Plugin | Role |
|--------|------|
| `lualine.nvim` | Status line |
| `bufferline.nvim` | Buffer tabs |
| `preservim/nerdtree` | Sidebar file explorer (`<leader>nn`, reveal anywhere with `<leader>nf`) |
| `oil.nvim` | Buffer-style file navigator (`-` key) |
| `nvim-ufo` | Folding with line count (`↙ N`) |
| `nvim-statuscol` | Custom sign/number column |
| `indent-blankline.nvim` | Indent & scope guides |
| `nvim-colorizer` | Hex color preview |
| `snacks.nvim` | Notification popups (replaces nvim-notify) + nicer `vim.ui.input` for LSP rename / input prompts |
| `nvim-bqf` | Enhanced quickfix window |
| `mini.icons` | File/LSP icons |

### Navigation
| Plugin | Role |
|--------|------|
| `fzf-lua` | Fuzzy finder with preview (files, grep, buffers) |
| `hop.nvim` | EasyMotion-style jump |
| `nvim-hlslens` | Search result count & highlights |
| `aerial.nvim` | Symbol outline via LSP/treesitter — no ctags needed (`<leader>ao`) |

### Git
| Plugin | Role |
|--------|------|
| `gitsigns.nvim` | Inline git blame & hunk signs |
| `neogit` | Interactive git UI |
| `vim-fugitive` | Git commands (`:G`) |
| `diffview.nvim` | Side-by-side diff viewer |
| `git-conflict.nvim` | Conflict marker highlighting |
| `gitlinker.nvim` | Copy permalink to GitHub/GitLab |

### Editing
| Plugin | Role |
|--------|------|
| `Comment.nvim` | Smart commenting (`gc`) |
| `which-key.nvim` | Keymap popup helper |
| `yanky.nvim` | Yank ring history |
| `vim-mundo` | Visual undo tree |
| `vim-swap` | Swap function arguments |
| `vim-matchup` | Better `%` matching |
| `better-escape.vim` | Fast `jj`/`jk` escape from insert mode |
| `live-command.nvim` | Live preview for `:s` substitute |
| `whitespace.nvim` | Trailing whitespace highlight |
| `todo-comments.nvim` | Highlight & navigate TODO/FIXME/HACK/NOTE/BUG |
| `grug-far.nvim` | Interactive project-wide find & replace |
| `ack.vim` | Search across files using ack / ripgrep (`:Ack`) |
| `vim-illuminate` | Auto-highlight all occurrences of word under cursor |
| `vim-mark` | Manually highlight multiple words in different colors (`<leader>m`) |
| `trouble.nvim` | Better diagnostics & quickfix UI |

### AI Assistant
| Plugin | Role |
|--------|------|
| `avante.nvim` | Cursor-like AI assistant — sidebar chat + inline diff editing backed by local vLLM (Devstral) |

### C/C++ Tools
| Plugin | Role |
|--------|------|
| `clangd_extensions.nvim` | Inlay hints, AST view, symbol info, memory usage |
| `cscope_maps.nvim` | Cscope keymaps for symbol navigation |

### Task Runner
| Plugin | Role |
|--------|------|
| `overseer.nvim` | Task runner with toggleable panel — run build/test/shell tasks (`<leader>o`) |
| `toggleterm.nvim` | Persistent floating terminal toggled with `<leader>tt`; `<Esc><Esc>` to exit |
| `persistence.nvim` | Auto-saves and restores sessions per working directory (`<leader>s`) |

### Debug (DAP)
| Plugin | Role |
|--------|------|
| `nvim-dap` | Debug Adapter Protocol client |
| `nvim-dap-ui` | Visual debugger UI (scopes, stacks, watches, REPL) |
| `nvim-dap-python` | Python debug adapter (debugpy) |

### Colorschemes
`everforest` · `gruvbox-material` · `sonokai` · `tokyonight` · `catppuccin` · `kanagawa` · `nightfox`

Pick a theme interactively with `<leader>uc` (fzf-lua picker). To set a permanent default, edit the last line of `init.lua`:
```lua
color_scheme.select_colorscheme("everforest")  -- change to any key above
```

---

## Key Mappings

> Leader key: `,`

### Windows
| Key | Action |
|-----|--------|
| `Ctrl-h/j/k/l` | Switch between split windows |
| `Ctrl-↑` | Increase window height (+2 lines) |
| `Ctrl-↓` | Decrease window height (-2 lines) |
| `Ctrl-→` | Increase window width (+2 columns) |
| `Ctrl-←` | Decrease window width (-2 columns) |

### Buffers
| Key | Action |
|-----|--------|
| `\d` | Delete current buffer (force — works on binary files too) |
| `\D` | Delete all other buffers (force) |

### Files & Search
| Key | Action |
|-----|--------|
| `<Space>f` | Fuzzy find files with preview (fzf-lua) |
| `,fg` | Live grep / ripgrep with preview |

### Navigation
| Key | Action |
|-----|--------|
| `f` | Hop jump (EasyMotion-style) |
| `*` / `#` / `n` / `N` | Search with hlslens highlights |
| `]f` / `[f` | Jump to next/previous function (mini.ai) |
| `]c` / `[c` | Jump to next/previous class (mini.ai) |
| `<leader>ao` | Toggle aerial symbol outline (LSP/treesitter) |

### Folding
| Key | Action |
|-----|--------|
| `zM` | Close all folds |
| `zR` | Open all folds |
| `za` | Toggle fold under cursor |
| `zo` | Open fold under cursor |
| `zO` | Open fold recursively |
| `,fm` | Toggle fold method (expr ↔ manual) — freeze folds while editing |

### Terminal
| Key | Action |
|-----|--------|
| `,tt` | Open terminal in bottom split (15 lines) |
| `Esc` | Exit terminal mode → normal mode |
| `Ctrl-\ Ctrl-n` | Exit terminal mode (fallback) |
| `Ctrl-w w` | Switch back to editor window |

### Git
| Key | Action |
|-----|--------|
| `:G` | Fugitive git UI |
| `:DiffviewOpen` | Open diff viewer |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `,ca` | Code action |
| `,rn` | Rename symbol |

> **Diagnostics**: virtual lines are shown inline beneath the cursor line only (`virtual_lines = { only_on_cursor = true }`). A float with full detail (source, prefix) opens automatically on `CursorHold`.

### Completion
| Key | Action |
|-----|--------|
| `Tab` | Next item / expand snippet / jump forward |
| `Shift-Tab` | Previous item / jump backward |
| `Enter` | Confirm completion |
| `Ctrl-e` | Abort completion |
| `Ctrl-d` / `Ctrl-f` | Scroll docs down / up |

### Markdown
| Key / Command | Action |
|---------------|--------|
| `,mp` | Toggle browser preview (markdown-preview.nvim) |
| `:MarkdownPreview` | Open browser preview |
| `:MarkdownPreviewStop` | Close browser preview |
| `:Toc` | Open table of contents in quickfix |
| `:Toch` | TOC in horizontal split |
| `:TableFormat` | Auto-align table columns |
| `]]` / `[[` | Jump to next / previous heading |
| `ge` | Follow link under cursor |

### fzf-lua Preview Scroll
| Key | Action |
|-----|--------|
| `Ctrl-d` | Preview page down |
| `Ctrl-u` | Preview page up |
| `Ctrl-e` | Preview line down |
| `Ctrl-y` | Preview line up |
| `Shift-↓` / `Shift-↑` | Preview scroll (arrow alternative) |

### Surround (mini.surround)
| Key | Action |
|-----|--------|
| `sa{motion}{char}` | Add surround — e.g. `saiw"` wraps word in `"..."` |
| `sd{char}` | Delete surround — e.g. `sd"` removes surrounding quotes |
| `sr{old}{new}` | Replace surround — e.g. `sr"'` changes `"..."` to `'...'` |
| `sf` / `sF` | Find next / previous surrounding |

### TODO Comments
| Key / Command | Action |
|---------------|--------|
| `]t` | Jump to next TODO/FIXME/HACK/NOTE comment |
| `[t` | Jump to previous TODO comment |
| `,ft` | List all TODOs in fzf-lua |
| `:TodoQuickFix` | Load all TODOs into quickfix list |

### Ack (ack.vim)
| Key / Command | Action |
|---------------|--------|
| `,ak` | Search word under cursor across project (literal, safe for C/C++) |
| `,akk` | Open `:Ack! ""` prompt — literal search, spaces allowed |
| `,akr` | Open `:AckRegex ""` prompt — regex search |
| `v` + `,ak` | Search visual selection across project (literal) |
| `,akc` | Clear Ack match highlights |
| `:AckRegex {pat}` | Search with regex — use when you need `(`, `*`, `\d` etc. |

> Default backend is ripgrep with `--fixed-strings` so C/C++ expressions like `func(a, b)` work without escaping. Use `,akr` / `:AckRegex` when you need real regex.

### Project Find & Replace (grug-far)
| Key / Command | Action |
|---------------|--------|
| `,rp` | Open grug-far panel (search & replace across project) |
| `,rw` | Open panel pre-filled with word under cursor |
| `v` + `,rp` | Open panel pre-filled with visual selection |

### Debug (DAP)
| Key | Action |
|-----|--------|
| `,dc` | Continue / start debug session |
| `,db` | Toggle breakpoint |
| `,dB` | Conditional breakpoint (prompts for condition) |
| `,do` | Step over |
| `,di` | Step into |
| `,dO` | Step out |
| `,dr` | Open REPL |
| `,dl` | Re-run last debug session |
| `,dx` | Terminate session |
| `,du` | Toggle DAP UI (auto-opens with session) |

### C/C++ Tools
| Key | Action |
|-----|--------|
| `,as` | Switch header/source (clangd) |
| `,ih` | Toggle inlay hints |
| `,si` | Symbol info |
| `,at` | View AST |
| `,mu` | clangd memory usage |

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

### Session (persistence.nvim)
| Key | Action |
|-----|--------|
| `<leader>ss` | Restore session for current working directory |
| `<leader>sl` | Restore last session (any directory) |
| `<leader>sq` | Stop persistence — don't save session on exit |

### Terminal (toggleterm.nvim)
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle floating terminal |

> Inside the terminal: `<Esc><Esc>` returns to normal mode.

### Task Runner (overseer.nvim)
| Key | Action |
|-----|--------|
| `<leader>ot` | Toggle task list panel |
| `<leader>or` | Run a task template (picker) |
| `<leader>oR` | Run a shell command as a task (`OverseerShell`) |

### UI Toggles
| Key | Action |
|-----|--------|
| `<leader>ub` | Blink cursor column/line to locate cursor |
| `<leader>uc` | Pick colorscheme interactively (fzf-lua) |
| `<leader>ux` | Toggle treesitter context bar |
| `<leader>tf` | Toggle format-on-save (conform.nvim) |
| `<leader>fm` | Toggle fold method: treesitter expr ↔ manual |

### AI Assistant (avante.nvim)
| Key | Action |
|-----|--------|
| `<leader>ia` | Ask AI — open sidebar chat |
| `<leader>ie` | Edit — inline diff (visual-select code first) |
| `<leader>it` | Toggle sidebar |
| `<leader>ir` | Refresh last request |

### User Commands
| Command | Action |
|---------|--------|
| `:Format` | Format current buffer (conform.nvim / LSP fallback) |
| `:LspInfo2` | Show active LSP clients for current buffer |
| `:ReloadConfig` | Reload `init.lua` without restarting |
| `:LspRestart` | Restart all LSP clients (Neovim 0.11 compatible) |
| `:MesonSetup [pkg ...]` | `meson setup` + symlink `compile_commands.json`, restart LSP |
| `:MesonBuild [pkgdir]` | `meson compile -C builddir` in a terminal split |
| `:MesonLink [builddir]` | Re-create `compile_commands.json` symlink only |
| `:GccDebug [output]` | Compile current C/C++ file with `-g -O0` for DAP |
| `:KernelSetup [build_root]` | Generate `compile_commands.json` + `.clangd` for OpenBMC/Yocto kernel |
| `:OEPkgSetup [pkg]` | Link bitbake's `compile_commands.json` to source root for any OE/Yocto package |
| `:lua Snacks.notifier.show_history()` | Browse past notifications (snacks.nvim) |

---

## File Structure

```
repo/                         # Top-level repository
├── install.sh                # Installer — sets up tools and links nvim/ to ~/.config/nvim
├── build_nvim.sh             # Optional — build latest Neovim from source
├── README.md                 # This file
└── nvim/                     # Actual Neovim config (installed as ~/.config/nvim)
    ├── init.lua              # Entry point
    ├── lua/
    │   ├── globals.lua       # Global variables
    │   ├── mappings.lua      # Key mappings
    │   ├── custom-autocmd.lua    # Autocommands
    │   ├── custom-commands.lua   # :Format, :LspInfo2, :ReloadConfig
    │   ├── colorschemes.lua      # Colorscheme loader & selector
    │   ├── diagnostic-conf.lua   # LSP diagnostic display config
    │   ├── plugin_specs.lua      # All plugin definitions (Lazy.nvim)
    │   └── config/               # Per-plugin config files
    │       ├── ack.lua           # ack.vim: literal + regex search, keymaps
    │       ├── dap.lua           # DAP core: signs, LLDB adapter, keymaps
    │       ├── dap-ui.lua        # DAP UI layout; auto open/close with session
    │       └── ...               # (one file per other plugin)
    ├── viml_conf/
    │   ├── options.vim           # Vim options (folds, tabs, UI)
    │   └── plugins.vim           # VimScript plugin settings
    ├── my_snippets/              # Custom UltiSnips snippets
    ├── after/                    # Filetype-specific overrides
    ├── ftdetect/                 # Custom filetype detection
    └── spell/                    # Spell check word lists
```

---

## Troubleshooting

**`too many open files` error (git plugins)**
```bash
# Check current limit
ulimit -n

# Fix permanently
echo "ulimit -n 4096" >> ~/.bashrc && source ~/.bashrc
```

**Markdown preview not working**
Requires `node` and `npm`. Run inside nvim:
```
:call mkdp#util#install()
```

**Treesitter parsers not installed**
Parsers auto-install on first launch via `LazyDone` autocmd. If they fail, run manually:
```
:TSInstall! c cpp lua python bash vim vimdoc
```

**Plugins not loading / broken**
```
:Lazy sync
```
Or for a full reset:
```
:Lazy clean
:Lazy install
```

**Icons not showing**
Install a Nerd Font and configure it in your terminal emulator.
[Download Nerd Fonts](https://www.nerdfonts.com/font-downloads)

**Folds re-closing after edits**
Press `,fm` to switch from `expr` to `manual` fold mode — this freezes
folds in their current state so edits don't trigger re-folding.
Press `,fm` again to re-enable treesitter fold detection.

**DAP: no adapter found for C/C++**
Install `lldb` and ensure `lldb-dap` (or the older `lldb-vscode`) is on your PATH:
```bash
sudo apt install lldb          # Debian/Ubuntu
brew install llvm              # macOS
```
Then verify: `which lldb-dap`

**DAP: Python breakpoints not hitting**
Install `debugpy` in the Python environment you run your project with:
```bash
pip install debugpy
```
The adapter uses whichever `python3` is on your PATH at startup.

