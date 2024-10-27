# Command Aliases
abbr -a g git
abbr -a m make

# File location Aliases
alias ..="cd ..; ls"
alias ...="cd ../..; ls"
alias p="pwd; ls"

alias des="cd $HOME/Desktop; ls"
alias dow="cd $HOME/Downloads; ls"
alias home="cd $HOME; ls"
alias repo="cd $HOME/repo; ls"

alias bat=batcat # https://github.com/sharkdp/bat/issues/982 

# Type "d" to move to top parent git dir
function d
    while test $PWD != "/"
        if test -d .git
            break
        end
        cd ..
    end
end

# File listing Aliases
alias c="clear"

alias l="ls -lhvF"
alias ls="ls -lhvF"
alias la="ls -lhvFA"
alias lc="ls -lhvcr"
alias ls="ls --color"

# Disk usage aliases
alias du="du -h"
alias du0="du -sh * | sort -hr"
alias du1="du -hxd 1 | sort -hr"

# Add verbosity by default
alias cp="cp -v"
alias mv="mv -v"
alias rm="rm -v"
alias rsync="rsync -v"

# Update package manager
alias upd="sudo apt update && sudo apt upgrade -y"

# Start tmux session
alias tm="tmux -f $HOME/.config/tmux/tmux.conf"

# Find free ports
alias ports="netstat -tulna"

# Get user processes
alias procs="ps aux | grep $USER"

# Get weather
alias weather="curl -s \"wttr.in/?format=3\""

# Fish cursor
set fish_cursor_unknown block

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'none'

# Fish prompt
set -g fish_prompt_pwd_dir_length 3

# Remove fish greeting
set -g fish_greeting

function fish_prompt
    set_color brblack
    echo -n "["(date "+%H:%M")"] "
    set_color blue
    echo -n (hostname)
    if [ $PWD != $HOME ]
        set_color brblack
        echo -n ":"
        set_color yellow
        echo -n (basename $PWD)
    end
    set_color green
    printf '%s ' (__fish_git_prompt)
    set_color normal
    echo -n '| '
end

# Java 11 JDK
set --export JAVA_HOME (dirname (dirname (readlink -f (which java))))
set -gx PATH $JAVA_HOME $PATH

# Batcat
set -Ua fish_user_paths /usr/bin/batcat

# Bin
set -Ua fish_user_paths /home/kuba/bin/.local/scripts/

# Emacs
alias em="emacsclient -c"

# Vivify
set -Ua fish_user_paths /usr/bin/vivify-linux/

# Editor
alias vi="nvim"
alias e="nvim"
alias vim="nvim"
