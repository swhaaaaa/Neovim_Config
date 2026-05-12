#!/usr/bin/env bash
set -e

# SCRIPT_DIR  = top-level repo folder (where install.sh, build_nvim.sh, README.md live)
# NVIM_DIR    = the actual nvim config subfolder to install as ~/.config/nvim
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_DIR="$SCRIPT_DIR/nvim"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}$*${NC}"; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Neovim Enhanced Config Installer     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Detect package manager ───────────────────────────────────────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MGR="apt"
        PKG_UPDATE="sudo apt-get update -qq"
        PKG_INSTALL="sudo apt-get install -y"
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
        PKG_UPDATE="sudo dnf check-update -q || true"
        PKG_INSTALL="sudo dnf install -y"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
        PKG_UPDATE="sudo pacman -Sy --noconfirm"
        PKG_INSTALL="sudo pacman -S --noconfirm"
    elif command -v brew &>/dev/null; then
        PKG_MGR="brew"
        PKG_UPDATE="brew update"
        PKG_INSTALL="brew install"
    else
        PKG_MGR="unknown"
    fi
}

detect_pkg_manager
info "Detected package manager: ${BOLD}${PKG_MGR}${NC}"

# ─── Install helper ───────────────────────────────────────────────────────────
# Usage: install_pkg <cmd_to_check> <pkg_name_apt> <pkg_name_dnf> <pkg_name_pacman> <pkg_name_brew> <description>
install_if_missing() {
    local cmd="$1"
    local pkg_apt="$2"
    local pkg_dnf="$3"
    local pkg_pacman="$4"
    local pkg_brew="$5"
    local desc="$6"

    if command -v "$cmd" &>/dev/null; then
        success "$cmd already installed"
        return
    fi

    warn "$cmd not found ($desc)"
    read -rp "  Install $cmd now? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        warn "Skipping $cmd"
        return
    fi

    case "$PKG_MGR" in
        apt)     $PKG_INSTALL "$pkg_apt"    ;;
        dnf)     $PKG_INSTALL "$pkg_dnf"    ;;
        pacman)  $PKG_INSTALL "$pkg_pacman" ;;
        brew)    $PKG_INSTALL "$pkg_brew"   ;;
        *)       warn "Cannot auto-install $cmd — unknown package manager. Install manually." ; return ;;
    esac

    if command -v "$cmd" &>/dev/null; then
        success "$cmd installed successfully"
    else
        warn "$cmd installation may have failed — check manually"
    fi
}

# ─── Install Neovim if missing ────────────────────────────────────────────────
step "── Step 1: Neovim ──────────────────────────────────────────"

install_neovim() {
    info "Installing Neovim >= 0.11..."
    if [ "$PKG_MGR" = "apt" ]; then
        # apt often ships an old nvim — use the official AppImage instead
        info "Using official Neovim AppImage for latest version..."
        NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.appimage"
        curl -fLo /tmp/nvim.appimage "$NVIM_URL"
        chmod +x /tmp/nvim.appimage
        sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
    elif [ "$PKG_MGR" = "dnf" ]; then
        sudo dnf install -y neovim
    elif [ "$PKG_MGR" = "pacman" ]; then
        sudo pacman -S --noconfirm neovim
    elif [ "$PKG_MGR" = "brew" ]; then
        brew install neovim
    else
        error "Cannot auto-install Neovim. Visit: https://github.com/neovim/neovim/releases"
    fi
}

if ! command -v nvim &>/dev/null; then
    warn "Neovim not found"
    read -rp "  Install Neovim now? [Y/n] " answer
    answer="${answer:-Y}"
    [[ "$answer" =~ ^[Yy]$ ]] && install_neovim || error "Neovim is required. Aborting."
fi

NVIM_VERSION=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')
NVIM_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)
if [ "$NVIM_MINOR" -lt 11 ]; then
    error "Neovim >= 0.11 required. Found: $NVIM_VERSION — please upgrade."
fi
success "Neovim $NVIM_VERSION"

# ─── Required dependencies ────────────────────────────────────────────────────
step "── Step 2: Required Dependencies ─────────────────────────"

install_if_missing "git"  "git"         "git"         "git"         "git"         "required by Lazy.nvim and all git plugins"
install_if_missing "curl" "curl"        "curl"        "curl"        "curl"        "required for downloads"

# ─── Optional but strongly recommended ───────────────────────────────────────
step "── Step 3: Recommended Tools ──────────────────────────────"

install_if_missing "rg"     "ripgrep"           "ripgrep"       "ripgrep"         "ripgrep"         "live grep in fzf-lua and grug-far"
install_if_missing "fzf"    "fzf"               "fzf"           "fzf"             "fzf"             "fuzzy finder — required by fzf-lua"
install_if_missing "ctags"  "universal-ctags"   "ctags"         "ctags"           "universal-ctags" "symbol browser for Vista.vim"
install_if_missing "cscope" "cscope"            "cscope"        "cscope"          "cscope"          "C/C++ symbol navigation (cscope_maps.nvim)"
install_if_missing "node"   "nodejs"            "nodejs"        "nodejs"          "node"            "required by many LSP servers and Markdown preview"
install_if_missing "npm"    "npm"               "npm"           "npm"             "node"            "required to install LSP servers and Markdown preview"

# ack — used by ack.vim as search backend (ripgrep is preferred if available,
# but ack is kept as a fallback and is the plugin's namesake tool).
# On Debian/Ubuntu the package is called ack or ack-grep depending on version.
if command -v ack &>/dev/null || command -v ack-grep &>/dev/null; then
    success "ack already installed"
else
    warn "ack not found (search backend for ack.vim — ripgrep preferred but ack is fallback)"
    read -rp "  Install ack now? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        case "$PKG_MGR" in
            apt)
                # Ubuntu 20.04+ ships as 'ack'; older releases used 'ack-grep'
                if apt-cache show ack &>/dev/null 2>&1; then
                    sudo apt-get install -y ack
                else
                    sudo apt-get install -y ack-grep
                fi
                ;;
            dnf)    sudo dnf install -y ack ;;
            pacman) sudo pacman -S --noconfirm ack ;;
            brew)   brew install ack ;;
            *)      warn "Cannot auto-install ack — unknown package manager. Install manually." ;;
        esac

        if command -v ack &>/dev/null || command -v ack-grep &>/dev/null; then
            success "ack installed"
        else
            warn "ack installation may have failed — check manually"
        fi
    else
        info "Skipping ack. ack.vim will use ripgrep (rg) as backend if available."
    fi
fi

# ─── Formatters ───────────────────────────────────────────────────────────────
step "── Step 4: Formatters ──────────────────────────────────────"

# stylua (Lua formatter)
if ! command -v stylua &>/dev/null; then
    warn "stylua not found (Lua formatter for conform.nvim)"
    read -rp "  Install stylua via cargo? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v cargo &>/dev/null; then
            cargo install stylua
            success "stylua installed"
        else
            warn "cargo not found — install Rust first: https://rustup.rs"
            warn "Or download stylua binary from: https://github.com/JohnnyMorganz/StyLua/releases"
        fi
    fi
else
    success "stylua already installed"
fi

# ruff (Python formatter/linter)
if ! command -v ruff &>/dev/null; then
    warn "ruff not found (Python formatter for conform.nvim)"
    read -rp "  Install ruff via pip? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v pip3 &>/dev/null; then
            pip3 install ruff --user
            success "ruff installed"
        elif command -v pip &>/dev/null; then
            pip install ruff --user
            success "ruff installed"
        else
            warn "pip not found — install Python first"
        fi
    fi
else
    success "ruff already installed"
fi

# prettier (JS/TS formatter)
if ! command -v prettier &>/dev/null; then
    warn "prettier not found (JS/TS formatter)"
    read -rp "  Install prettier via npm? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v npm &>/dev/null; then
            sudo npm install -g prettier
            success "prettier installed"
        else
            warn "npm not found — skipping prettier"
        fi
    fi
else
    success "prettier already installed"
fi

# tree-sitter CLI (required by nvim-treesitter to compile parsers)
if ! command -v tree-sitter &>/dev/null; then
    warn "tree-sitter CLI not found (required to compile Treesitter parsers)"
    read -rp "  Install tree-sitter-cli via npm? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v npm &>/dev/null; then
            sudo npm install -g tree-sitter-cli
            success "tree-sitter-cli installed"
        else
            warn "npm not found — skipping tree-sitter-cli"
        fi
    fi
else
    success "tree-sitter already installed"
fi

# ─── Debug adapters (DAP) ─────────────────────────────────────────────────────
step "── Step 5: Debug Adapters (DAP) ─────────────────────────────"

# lldb-dap — C/C++ debug adapter (part of the lldb package)
# Checks for both the new name (lldb-dap) and the old name (lldb-vscode).
# On Ubuntu/Debian, apt installs the binary at a versioned path like
# /usr/lib/llvm-18/bin/lldb-vscode, not on PATH — we find and symlink it.

_find_and_link_lldb() {
    # Search versioned llvm paths for either binary name
    local found=""
    for bin in lldb-dap lldb-vscode; do
        found=$(find /usr/lib/llvm-*/bin -name "$bin" 2>/dev/null | sort -V | tail -1)
        [ -n "$found" ] && break
    done

    if [ -z "$found" ]; then
        warn "lldb installed but no lldb-dap or lldb-vscode binary found under /usr/lib/llvm-*/"
        info "  Check your lldb version or install llvm: sudo apt install llvm"
        return 1
    fi

    info "  Found: $found"
    sudo ln -sf "$found" /usr/local/bin/lldb-dap
    if command -v lldb-dap &>/dev/null; then
        success "lldb-dap symlinked → /usr/local/bin/lldb-dap"
    else
        warn "Symlink created but lldb-dap still not on PATH — check \$PATH includes /usr/local/bin"
    fi
}

if command -v lldb-dap &>/dev/null || command -v lldb-vscode &>/dev/null; then
    success "lldb debug adapter already installed"
else
    warn "lldb-dap not found (C/C++ debugger for DAP)"
    read -rp "  Install lldb now? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        case "$PKG_MGR" in
            apt)    sudo apt-get install -y lldb ;;
            dnf)    sudo dnf install -y lldb ;;
            pacman) sudo pacman -S --noconfirm lldb ;;
            brew)   brew install llvm ;;
            *)      warn "Cannot auto-install lldb — unknown package manager. Install manually." ;;
        esac

        if command -v lldb-dap &>/dev/null || command -v lldb-vscode &>/dev/null; then
            success "lldb debug adapter installed and on PATH"
        else
            # Binary was installed but not put on PATH (common on Ubuntu/Debian)
            info "  Binary not on PATH — searching versioned llvm path..."
            _find_and_link_lldb
        fi
    else
        info "Skipping lldb. C/C++ debugging (DAP) will not work without it."
    fi
fi

# debugpy — Python debug adapter
# NOT installed system-wide here, because it must live inside the same Python
# environment as the project being debugged. We only check and inform.
if python3 -c "import debugpy" &>/dev/null 2>&1; then
    success "debugpy already available in current Python environment"
else
    warn "debugpy not found in current Python environment (Python DAP)"
    info "  debugpy must be installed in each project's virtualenv, not globally."
    info "  Install it when you need Python debugging:"
    info "    pip install debugpy"
    info "  Or inside a venv:  source .venv/bin/activate && pip install debugpy"
fi

# ─── Backup or remove existing config ────────────────────────────────────────
step "── Step 6: Config Setup ──────────────────────────────────"

if [ -e "$NVIM_CONFIG_DIR" ] || [ -L "$NVIM_CONFIG_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim_backup_$(date +%Y%m%d_%H%M%S)"
    info "Existing config found at $NVIM_CONFIG_DIR"
    read -rp "  Backup existing config to $BACKUP_DIR? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        cp -r "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        success "Backed up to $BACKUP_DIR"
    fi
    rm -rf "$NVIM_CONFIG_DIR"
    success "Removed old $NVIM_CONFIG_DIR"
fi

if [ -d "$NVIM_DATA_DIR" ]; then
    read -rp "  Remove old plugin data at $NVIM_DATA_DIR? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf "$NVIM_DATA_DIR"
        success "Removed $NVIM_DATA_DIR"
    fi
fi

# ─── lazy-lock.json ───────────────────────────────────────────────────────────
LOCK_FILE="$NVIM_DIR/lazy-lock.json"
if [ -e "$LOCK_FILE" ]; then
    success "lazy-lock.json found — keeping it to preserve pinned plugin versions"
    info "(Delete it manually only if you want a full fresh plugin resolution)"
fi

# ─── Install: symlink or copy ─────────────────────────────────────────────────
echo ""
info "Choose install method:"
echo "  1) Symlink (recommended — edits in $NVIM_DIR reflect immediately)"
echo "  2) Copy    (standalone — no dependency on this directory)"
read -rp "  Select [1/2, default=1]: " install_method
install_method="${install_method:-1}"

if [ "$install_method" = "2" ]; then
    cp -r "$NVIM_DIR" "$NVIM_CONFIG_DIR"
    success "Copied config to $NVIM_CONFIG_DIR"
else
    ln -s "$NVIM_DIR" "$NVIM_CONFIG_DIR"
    success "Symlinked $NVIM_DIR → $NVIM_CONFIG_DIR"
fi

# ─── ulimit fix ───────────────────────────────────────────────────────────────
CURRENT_ULIMIT=$(ulimit -n)
if [ "$CURRENT_ULIMIT" -lt 4096 ]; then
    echo ""
    warn "Open file limit is low (ulimit -n = $CURRENT_ULIMIT)"
    warn "This causes 'too many open files' errors with git plugins."
    read -rp "  Add 'ulimit -n 4096' to ~/.bashrc now? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if grep -q "ulimit -n 4096" "$HOME/.bashrc"; then
            success "ulimit -n 4096 already exists in ~/.bashrc — skipping"
        else
            echo "" >> "$HOME/.bashrc"
            echo "# Increased for Neovim git plugins" >> "$HOME/.bashrc"
            echo "ulimit -n 4096" >> "$HOME/.bashrc"
            success "Added ulimit to ~/.bashrc (takes effect on next shell)"
        fi
    fi
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation completed successfully!   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
info "Launch nvim — Lazy.nvim will auto-install all plugins on first start."
info "Treesitter parsers will auto-install via LazyDone autocmd on first launch."
info "If parsers fail, run manually inside nvim: :TSInstall! c cpp lua python bash"
info "For Markdown preview, run inside nvim: :call mkdp#util#install()"
echo ""
