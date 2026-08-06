# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Executable:  zsh
# Shell Tools: fzf, zsh-autosuggestions, zsh-syntax-highlighting
# Optional:    oh-my-zsh

# ==============================================================================
# Environment & Path Setup
# ==============================================================================

# Ensure Nix-installed binaries and personal scripts take priority
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.nix-profile/bin:$PATH"
export EDITOR="nvim"

# FZF interactive styling (Rose Pine)
export FZF_DEFAULT_OPTS='--color=bg:#090B10,fg:#e0def4,hl:#c4a7e7,fg+:#e0def4,bg+:#403d52,hl+:#9ccfd8,info:#6e6a86,prompt:#31748f,pointer:#ebbcba,marker:#eb6f92,spinner:#f6c177,header:#6e6a86,border:#26233a'

# ==============================================================================
# Zsh Options & History (Fish-like durability)
# ==============================================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt no_beep               # Silent terminal
setopt extended_glob         # Advanced pattern matching
setopt auto_pushd            # Track directory stack for easy 'popd'
setopt pushd_ignore_dups
setopt interactive_comments  # Allow # comments in shell
setopt PROMPT_SUBST          # Enable prompt parameter expansion

# History behavior
setopt append_history
setopt share_history         # Share history across terminal sessions real-time
setopt hist_ignore_space     # Don't record commands starting with space
setopt hist_ignore_all_dups  # Erase old duplicate entries when new one recorded
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks

# ==============================================================================
# Completion System (Fish-like Menu & Matching)
# ==============================================================================

autoload -Uz compinit && compinit

# Enable arrow-key menu selection for completions
zstyle ':completion:*' menu select

# Case-insensitive (all lower) / Case-sensitive (uppercase) completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colorize completion menu matching LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Auto-rehash commands (detect new installed binaries immediately)
zstyle ':completion:*' rehash true

# ==============================================================================
# Prompt & Window Title
# ==============================================================================

# Fast, native Git branch helper
zsh_git_branch() {
  local branch
  branch=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  echo "%F{242}(%F{111}git:${branch}%F{242}) "
}

# Construct Prompt: [time] hostname cwd (git-branch) %#
# %F{N} = 256-color foreground, %f = reset color
# %6~   = CWD auto-trimmed to 6 levels max (like PROMPT_DIRTRIM=6)
# %#    = % for regular user, # for root
PROMPT='%F{240}[%D{%H:%M}]%f '       # Grey timestamp [HH:MM]
PROMPT+='%F{174}%m%f '              # Muted rose hostname
PROMPT+='%F{116}%6~%f '             # Teal current working directory
PROMPT+='$(zsh_git_branch)'         # Soft blue Git branch
PROMPT+='%F{174}%#%f '              # Prompt symbol

# Terminal Title Hook (Replaces Bash PROMPT_COMMAND)
precmd_update_title() {
  local ssh_str=""
  [[ -n $SSH_CLIENT || -n $SSH_TTY ]] && ssh_str="[ssh] "
  print -Pn "\e]0;${ssh_str}%n@%m:%~\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_update_title

# ==============================================================================
# Keybindings & Vi Mode
# ==============================================================================

set -o vi
bindkey -v

# Arrow key substring history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Tab completion keymap
bindkey '^I' expand-or-complete

# ==============================================================================
# Framework & Plugins (Nix-aware fallbacks)
# ==============================================================================

# Oh My Zsh base initialization
export ZSH="$HOME/.nix-profile/share/oh-my-zsh"
plugins=(git)

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Zsh Autosuggestions (Fish-style inline ghost text)
if [[ -r "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -r "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# FZF Shell Integration
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Zsh Syntax Highlighting (MUST BE LOADED LAST)
if [[ -r "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -r "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ==============================================================================
# Aliases
# ==============================================================================

# Navigation
alias ..='cd ..; ls'
alias p='pwd'
alias des='cd $HOME/Desktop; ls'
alias dow='cd $HOME/Downloads; ls'
alias home='cd $HOME; ls'
alias repo='cd $HOME/repo; ls'

# Core tools
alias c='clear'
alias l='ls -lhvF --color=auto'
alias la='ls -lhvFA --color=auto'
alias grep='grep --color=auto'

# Disk & system info
alias du='du -h'
alias du0='du -sh * | sort -hr'
alias du1='du -hxd 1 | sort -hr'
alias procs='ps aux | grep $USER'
alias ports='netstat -tulna'
alias upd='sudo apt update && sudo apt upgrade -y'

# File operations
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias rsync='rsync -v'

# Tooling shortcuts
alias e='nvim'
alias g='git'
alias lg='lazygit'
alias tm='tmux'

# ==============================================================================
# Local Overrides
# ==============================================================================
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
