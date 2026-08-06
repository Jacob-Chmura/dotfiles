#!/usr/bin/env bash
# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Executable: bash
# Utilities:  curl, git, sed, nix (or internet access to install via Determinate)
# Target:     Fresh Linux / Distrobox instance

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Color & Logger setup
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN='' BLUE='' YELLOW='' RED='' BOLD='' NC=''
fi

info()    { printf "${BLUE}${BOLD}==>${NC} ${BOLD}%s${NC}\n" "$*"; }
success() { printf "${GREEN}${BOLD}[+]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}${BOLD}[!]${NC} %s\n" "$*"; }
error()   { printf "${RED}${BOLD}[x]${NC} %s\n" "$*" >&2; }

# ==============================================================================
# Step 1: Ensure Nix Installation
# ==============================================================================

info "Step 1: Checking Nix installation..."

if command -v nix >/dev/null 2>&1; then
  success "Nix is already installed."
else
  warn "Nix not found. Installing via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

  # Source Nix profile into current shell environment
  if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    # shellcheck disable=SC1091
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
  success "Nix installed and sourced successfully."
fi

# ==============================================================================
# Step 2: Establish Dotfiles Symlink
# ==============================================================================

info "Step 2: Linking repository to ~/.dotfiles..."

mkdir -p "$HOME/.config"
ln -sfn "$DIR" "$HOME/.dotfiles"
success "Symlinked $DIR -> $HOME/.dotfiles"

# ==============================================================================
# Step 3: Validate & Align Flake User Configuration
# ==============================================================================

info "Step 3: Validating user configuration in flake.nix..."

REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"

if [[ -z "$FLAKE_USER" ]]; then
  error "Could not find 'user = \"...\"' line in flake.nix."
  error "Please edit flake.nix manually before running bootstrap again."
  exit 1
elif [[ "$FLAKE_USER" != "$REAL_USER" ]]; then
  warn "flake.nix targets user '$FLAKE_USER', but current user is '$REAL_USER'."
  read -r -p "     Rewrite flake.nix user target to '$REAL_USER'? [y/N] " REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sed -i -E "s/^([[:space:]]*user = \")([^\"]+)(\";.*)/\1${REAL_USER}\3/" "$DIR/flake.nix"
    success "Updated flake.nix user to '$REAL_USER'."
  else
    error "Aborted. Update user target in flake.nix manually."
    exit 1
  fi
else
  success "flake.nix user matches active shell user ('$REAL_USER')."
fi

# ==============================================================================
# Step 4: Initial Home Manager Activation
# ==============================================================================

info "Step 4: Executing initial Home Manager switch..."

nix run home-manager -- switch --flake "path:${DIR}#${REAL_USER}" --impure

echo ""
success "Bootstrap complete. Environment active."
info "Run './rebuild.sh' for all subsequent configuration updates."
