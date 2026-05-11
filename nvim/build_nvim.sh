#!/usr/bin/env bash
set -e

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
echo -e "${CYAN}║     Neovim — Clone & Build Latest        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Detect package manager ───────────────────────────────────────────────────
if   command -v apt-get &>/dev/null; then PKG_MGR="apt"
elif command -v dnf     &>/dev/null; then PKG_MGR="dnf"
elif command -v pacman  &>/dev/null; then PKG_MGR="pacman"
elif command -v brew    &>/dev/null; then PKG_MGR="brew"
else                                      PKG_MGR="unknown"
fi
info "Package manager: ${BOLD}${PKG_MGR}${NC}"

# ─── Install build dependencies ───────────────────────────────────────────────
step "── Step 1: Install Build Dependencies ──────────────────────"

install_build_deps() {
    case "$PKG_MGR" in
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y \
                git cmake ninja-build gettext \
                libtool libtool-bin autoconf automake \
                pkg-config unzip curl doxygen \
                gcc g++ make \
                lua5.1 liblua5.1-dev luajit libluajit-5.1-dev \
                libmsgpack-dev libtermkey-dev libvterm-dev \
                libutf8proc-dev libunibilium-dev
            ;;
        dnf)
            sudo dnf install -y \
                git cmake ninja-build gettext \
                libtool autoconf automake \
                pkg-config unzip curl doxygen \
                gcc gcc-c++ make \
                compat-lua-libs luajit luajit-devel \
                libluv-devel msgpack-devel libtermkey-devel \
                libvterm-devel utf8proc-devel unibilium-devel
            ;;
        pacman)
            sudo pacman -Sy --noconfirm \
                git cmake ninja gettext \
                libtool autoconf automake \
                pkg-config unzip curl doxygen \
                gcc make \
                lua luajit luv msgpack-c libtermkey libvterm \
                utf8proc unibilium
            ;;
        brew)
            brew install git cmake ninja gettext libtool autoconf automake pkg-config doxygen
            ;;
        *)
            warn "Unknown package manager — please install build deps manually:"
            warn "  git cmake ninja gettext libtool autoconf automake pkg-config gcc make"
            warn "  Also install tree-sitter-cli via: npm install -g tree-sitter-cli"
            read -rp "  Continue anyway? [y/N] " answer
            [[ "$answer" =~ ^[Yy]$ ]] || exit 1
            ;;
    esac
}

read -rp "  Install/update build dependencies now? [Y/n] " answer
answer="${answer:-Y}"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    install_build_deps
    success "Build dependencies installed"
else
    warn "Skipping dependency install — build may fail if deps are missing"
fi

# ─── Choose install location ──────────────────────────────────────────────────
step "── Step 2: Clone Location ─────────────────────────────────"

DEFAULT_SRC="$HOME/sourcecode/neovim"
read -rp "  Clone Neovim source to [$DEFAULT_SRC]: " SRC_DIR
SRC_DIR="${SRC_DIR:-$DEFAULT_SRC}"

# ─── Clone or update ──────────────────────────────────────────────────────────
step "── Step 3: Clone / Update Neovim Source ───────────────────"

if [ -d "$SRC_DIR/.git" ]; then
    info "Existing repo found at $SRC_DIR — pulling latest..."
    cd "$SRC_DIR"
    git fetch --tags --force
    git checkout master
    git pull origin master
    success "Source updated"
else
    info "Cloning Neovim from GitHub..."
    mkdir -p "$(dirname "$SRC_DIR")"
    git clone https://github.com/neovim/neovim.git "$SRC_DIR"
    cd "$SRC_DIR"
    success "Cloned to $SRC_DIR"
fi

# ─── Choose version ───────────────────────────────────────────────────────────
step "── Step 4: Select Version ──────────────────────────────────"

LATEST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
info "Latest stable tag: ${BOLD}${LATEST_TAG}${NC}"
echo "  1) Latest stable ($LATEST_TAG)  ← recommended"
echo "  2) Nightly (master branch)"
read -rp "  Select [1/2, default=1]: " ver_choice
ver_choice="${ver_choice:-1}"

if [ "$ver_choice" = "2" ]; then
    info "Using nightly (master)..."
    git checkout master
    BUILD_TYPE="RelWithDebInfo"
else
    info "Checking out $LATEST_TAG..."
    git checkout "$LATEST_TAG"
    BUILD_TYPE="Release"
fi

# ─── Choose install prefix ────────────────────────────────────────────────────
step "── Step 5: Install Prefix ───────────────────────────────────"

echo "  1) /usr/local  (system-wide, requires sudo)"
echo "  2) ~/.local    (current user only, no sudo)"
read -rp "  Select [1/2, default=1]: " prefix_choice
prefix_choice="${prefix_choice:-1}"

if [ "$prefix_choice" = "2" ]; then
    INSTALL_PREFIX="$HOME/.local"
    SUDO_CMD=""
else
    INSTALL_PREFIX="/usr/local"
    SUDO_CMD="sudo"
fi
info "Install prefix: ${BOLD}${INSTALL_PREFIX}${NC}"

# ─── Build ────────────────────────────────────────────────────────────────────
step "── Step 6: Build ────────────────────────────────────────────"

cd "$SRC_DIR"

# Clean previous build artifacts
if [ -d "build" ] || [ -d ".deps" ]; then
    info "Cleaning previous build..."
    rm -rf build .deps
fi

CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
info "Building with $CPU_CORES cores (CMAKE_BUILD_TYPE=$BUILD_TYPE)..."

# Step 1: Build bundled third-party deps first (luv, msgpack, etc.)
info "Building bundled third-party dependencies..."
cmake -S cmake.deps -B .deps \
    -G Ninja \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build .deps --parallel "$CPU_CORES"

# Step 2: Build Neovim using the bundled deps
info "Building Neovim..."
cmake -S . -B build \
    -G Ninja \
    -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -D CMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

cmake --build build --parallel "$CPU_CORES"
success "Build complete"

# ─── Install ──────────────────────────────────────────────────────────────────
step "── Step 7: Install ──────────────────────────────────────────"

$SUDO_CMD cmake --install build
success "Neovim installed to $INSTALL_PREFIX"

# ─── Verify ───────────────────────────────────────────────────────────────────
step "── Step 8: Verify ───────────────────────────────────────────"

if command -v nvim &>/dev/null; then
    INSTALLED_VER=$(nvim --version | head -1)
    success "Installed: $INSTALLED_VER"
else
    warn "nvim not found in PATH — you may need to add $INSTALL_PREFIX/bin to PATH"
    echo ""
    echo "    Add this to ~/.bashrc:"
    echo "    export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
fi

# ─── PATH reminder for ~/.local installs ─────────────────────────────────────
if [ "$prefix_choice" = "2" ]; then
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        warn "~/.local/bin is not in your PATH"
        read -rp "  Add it to ~/.bashrc now? [Y/n] " answer
        answer="${answer:-Y}"
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            if ! grep -q 'export PATH="$HOME/.local/bin' ~/.bashrc; then
                echo '' >> ~/.bashrc
                echo '# Added by build_nvim.sh' >> ~/.bashrc
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                success "Added to ~/.bashrc (restart shell or run: source ~/.bashrc)"
            else
                success "Already in ~/.bashrc"
            fi
        fi
    fi
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Neovim built successfully!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
info "Source: $SRC_DIR"
info "Run 'nvim --version' to confirm."
echo ""
