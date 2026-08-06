#!/usr/bin/env bash
# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Executable: bash
# Utilities:  nix, sed

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Color & Logger setup
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN='' BLUE='' RED='' BOLD='' NC=''
fi

info()    { printf "${BLUE}${BOLD}==>${NC} ${BOLD}%s${NC}\n" "$*"; }
success() { printf "${GREEN}${BOLD}[+]${NC} %s\n" "$*"; }
error()   { printf "${RED}${BOLD}[x]${NC} %s\n" "$*" >&2; }

# Maintain mandatory symlink state
ln -sfn "$DIR" "$HOME/.dotfiles"

FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"

if [[ -z "$FLAKE_USER" ]]; then
  error "Could not parse target 'user' variable from flake.nix."
  exit 1
fi

info "Rebuilding Home Manager environment for '${FLAKE_USER}'..."

nix run home-manager -- switch --flake "path:${DIR}#${FLAKE_USER}" --impure

echo ""
success "Home Manager configuration successfully re-applied."
