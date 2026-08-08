#!/usr/bin/env bash

selected="${1:-$(find ~/repo/ ~/.config/nvim -mindepth 1 -maxdepth 1 -type d | fzf)}"
[[ -z "$selected" ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

if [[ -z "$TMUX" ]]; then
    # Outside tmux: attach if it exists, otherwise create and attach
    tmux new-session -A -s "$selected_name" -c "$selected"
else
    # Inside tmux: create detached if missing, then switch client
    tmux new-session -ds "$selected_name" -c "$selected" 2>/dev/null
    tmux switch-client -t "$selected_name"
fi
