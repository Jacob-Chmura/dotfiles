#!/usr/bin/env bash
set -euo pipefail

echo "[*] Starting bootstrap"

HAS_SUDO=false
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    echo "[✓] User has sudo privileges"
    HAS_SUDO=true
else
    echo "[!] No sudo privileges!"
fi

HOME_BIN="$HOME/.local/bin"
mkdir -p "$HOME_BIN"

check_prereqs() {
    [[ "$(uname -s)" == "Linux" ]] || { 
        echo "[!] Why aren't you on Linux?"; 
        exit 1; 
    }

    REQUIRED_CMDS=(git tar make cmake curl)
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "[!] $cmd is required but not found" >&2
            exit 1
        else
            echo "[✓] Found $cmd"
        fi
    done
}

install_rust() {
    if command -v rustc >/dev/null 2>&1; then
        echo "[✓] Found Rust"
    else
        echo "[*] Installing Rust"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        . "$HOME/.cargo/env"
        echo "[✓] Rust installed: $(rustc --version)"
    fi
}

install_cargo_tools() {
    local tools=(fd-find ripgrep proximity-sort eza)
    echo "[*] Installing Rust tools: ${tools[*]}"
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "[✓] Found $tool"
        else
            cargo install --quiet "$tool"
            echo "[✓] Installed $tool"
        fi
    done
}

install_uv() {
    if command -v uv >/dev/null 2>&1; then
        echo "[✓] Found uv"
    else
        echo "[*] Installing uv"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

install_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        echo "[✓] Found fzf"
    else
        echo "[*] Installing fzf"
        git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --bin --no-update-rc --no-bash --no-fish --no-zsh
        ln -sf "$HOME/.fzf/bin/fzf" "$HOME_BIN/fzf"
    fi
}

install_fish() {
    if command -v fish >/dev/null 2>&1; then
        echo "[✓] Found fish"
        return
    fi

    echo "[*] Installing Fish shell"
    FISH_VERSION="4.2.1"
    FISH_ARCHIVE="fish-${FISH_VERSION}-linux-x86_64.tar.xz"
    FISH_URL="https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/$FISH_ARCHIVE"
    curl -LO "$FISH_URL"
    tar -xf "$FISH_ARCHIVE" -C /tmp
    cp /tmp/fish "$HOME_BIN/fish"
    chmod +x "$HOME_BIN/fish"

    # Append auto-launch Fish snippet to bashrc
    if ! grep -q 'exec fish' "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" <<'EOF'

# Auto-launch Fish for interactive shells
if [[ $- == *i* ]]; then
    exec fish
fi
EOF
        echo "[✓] Added Fish auto-launch to ~/.bashrc"
    else
        echo "[✓] Fish auto-launch already configured in ~/.bashrc"
    fi
}

install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        echo "[✓] Found chezmoi"
    else
        echo "[*] Installing chezmoi"
        cd "$HOME"
        sh -c "$(curl -fsLS get.chezmoi.io/lb)"
    fi

    GITHUB_USERNAME="Jacob-Chmura"
    $HOME_BIN/chezmoi  init --apply "$GITHUB_USERNAME"
    echo "[✓] Dotfiles applied successfully for $GITHUB_USERNAME"
}

install_nvim() {
    if command -v nvim >/dev/null 2>&1; then
        echo "[✓] Found Neovim"
        return
    fi

    echo "[*] Installing Neovim"
    NVIM_APPIMAGE="/tmp/nvim-linux-x86_64.appimage"
    NVIM_EXTRACT_DIR="/tmp/nvim-appimage"
    cd /tmp
    curl -Lo "$NVIM_APPIMAGE" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x "$NVIM_APPIMAGE"
    rm -rf "$NVIM_EXTRACT_DIR"
    "$NVIM_APPIMAGE" --appimage-extract
    mv /tmp/squashfs-root "$NVIM_EXTRACT_DIR"
    ln -sf "$NVIM_EXTRACT_DIR/AppRun" "$HOME_BIN/nvim"
}

install_tmux() {
    if command -v tmux >/dev/null 2>&1; then
        echo "[✓] Found tmux"
        return
    fi

    if $HAS_SUDO; then
        echo "[*] Installing tmux with sudo..."
        sudo apt update -y || true && sudo apt install -y tmux
        return
    fi

    echo "[*] Installing tmux and dependencies locally..."
    export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export LD_LIBRARY_PATH="$HOME/.local/lib:${LD_LIBRARY_PATH:-}"

    # pkg-config
    cd /tmp
    curl -LO https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
    tar xf pkg-config-0.29.2.tar.gz && cd pkg-config-0.29.2
    ./configure --prefix="$HOME/.local" --with-internal-glib
    make -j"$(nproc)" && make install
    echo "[✓] pkg-config installed at $HOME/.local/bin/pkg-config"

    # libevent
    git clone --quiet https://github.com/libevent/libevent.git
    cd libevent
    mkdir -p build && cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
        -DEVENT__DISABLE_OPENSSL=ON \
        -DEVENT__DISABLE_TESTS=ON

    make -j$(nproc) && make install
    echo "[✓] libevent installed into $HOME/.local"

    # ncurses
    curl -L -o ncurses-6.4.tar.gz https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz
    tar xzf ncurses-6.4.tar.gz && cd ncurses-6.4
    ./configure --prefix="$HOME/.local" --with-shared --enable-pc-files --with-pkg-config-libdir="$HOME/.local/lib/pkgconfig"
    make -j$(nproc) && make install
    echo "[✓] ncurses installed into $HOME/.local"

    # yacc
    cd /tmp
    curl -LO https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz
    tar xf m4-1.4.19.tar.gz && cd m4-1.4.19
    ./configure --prefix=$HOME/.local
    make -j$(nproc) && make install
    echo "[✓] yacc installed into $HOME/.local"

    # bison
    cd /tmp
    curl -LO https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.gz
    tar xf bison-3.8.2.tar.gz && cd bison-3.8.2
    export PATH="$HOME/.local/bin:$PATH"
    ./configure --prefix=$HOME/.local
    make -j$(nproc) && make install
    echo "[✓] bison installed into $HOME/.local"

    # tmux
    echo "[*] Downloading tmux..."
    cd /tmp
    curl -L -o tmux-3.5a.tar.gz https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
    tar xzf tmux-3.5a.tar.gz && cd tmux-3.5a
    ./configure --prefix="$HOME/.local" \
        LDFLAGS="-L$HOME/.local/lib" \
        CPPFLAGS="-I$HOME/.local/include" \
        PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig"
    make -j$(nproc) && make install
    echo "[✓] tmux installed: $HOME/.local/bin/tmux"
}

install_alacritty(){
    if $HAS_SUDO; then
        echo "[*] Installing Alacritty with sudo..."
        sudo apt update -y || true && sudo apt install -y alacritty
    else
        echo "[!] Cannot install Alacritty: sudo privileges required."
    fi
}

install_npm() {
    if command -v npm >/dev/null 2>&1; then
        echo "[✓] Found npm"
        return
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install 24
}

check_prereqs
install_uv
install_rust
install_cargo_tools
install_fzf
install_chezmoi
install_nvim
install_tmux
install_alacritty
install_npm
install_fish # Must be last to not mess up bash-style exports from previous installs

echo "[✓] Bootstrap complete! Source ~./bashrc"
