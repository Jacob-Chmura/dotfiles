#!/usr/bin/env bash
# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Executable: bash
# Utilities:  curl, git, sed, nix (or internet access to install via Determinate)
# Target:     Fresh Linux / Distrobox instance or existing Nix installation

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BOOTSTRAP=false

if [[ "${1:-}" == "--bootstrap" || "${1:-}" == "-b" || "$(basename "$0")" == "bootstrap.sh" ]]; then
  BOOTSTRAP=true
fi

# Color & Logger setup
if [[ -t 1 ]]; then
  GREEN='\033[0;32m' BLUE='\033[0;34m' YELLOW='\033[0;33m' RED='\033[0;31m' BOLD='\033[1m' NC='\033[0m'
else
  GREEN='' BLUE='' YELLOW='' RED='' BOLD='' NC=''
fi

info()    { printf "${BLUE}${BOLD}==>${NC} ${BOLD}%s${NC}\n" "$*"; }
success() { printf "${GREEN}${BOLD}[+]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}${BOLD}[!]${NC} %s\n" "$*"; }
error()   { printf "${RED}${BOLD}[x]${NC} %s\n" "$*" >&2; }

# ==============================================================================
# Step 1: Bootstrap Prerequisites (Bootstrap Only)
# ==============================================================================
if [[ "$BOOTSTRAP" == true ]]; then
  info "Checking Nix installation..."

  if command -v nix >/dev/null 2>&1; then
    success "Nix is already installed."
  else
    warn "Nix not found. Installing via Determinate Systems installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

    for profile in "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
      if [[ -f "$profile" ]]; then
        # shellcheck disable=SC1090
        . "$profile"
        break
      fi
    done
    success "Nix installed and sourced successfully."
  fi
fi

# ==============================================================================
# Step 2: Maintain Symlink
# ==============================================================================
info "Linking repository to ~/.dotfiles..."

mkdir -p "$HOME/.config"
ln -sfn "$DIR" "$HOME/.dotfiles"
success "Symlinked $DIR -> $HOME/.dotfiles"

# ==============================================================================
# Step 3: Validate & Align Flake User Configuration
# ==============================================================================
info "Validating user configuration in flake.nix..."

REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"

if [[ -z "$FLAKE_USER" ]]; then
  error "Could not parse 'user' variable from flake.nix."
  exit 1
fi

if [[ "$BOOTSTRAP" == true && "$FLAKE_USER" != "$REAL_USER" ]]; then
  warn "flake.nix targets user '$FLAKE_USER', but current user is '$REAL_USER'."
  read -r -p "    Rewrite flake.nix user target to '$REAL_USER'? [y/N] " REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sed -i -E "s/^([[:space:]]*user = \")([^\"]+)(\";.*)/\1${REAL_USER}\3/" "$DIR/flake.nix"
    FLAKE_USER="$REAL_USER"
    success "Updated flake.nix user to '$REAL_USER'."
  else
    error "Aborted. Update user target in flake.nix manually."
    exit 1
  fi
else
  success "Using target user '$FLAKE_USER'."
fi

# ==============================================================================
# Step 4: Home Manager Activation
# ==============================================================================
info "Executing Home Manager switch for '$FLAKE_USER'..."

nix run home-manager -- switch --flake "path:${DIR}#${FLAKE_USER}" --impure

echo ""
success "Configuration successfully applied."
