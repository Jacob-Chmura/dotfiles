abbr -a e nvim
abbr -a vi nvim
abbr -a vim nvim
abbr -a vimdiff 'nvim -d'

abbr -a yr 'cal -y'
abbr -a m make
abbr -a o xdg-open

abbr -a g git
abbr -a gc 'git checkout'
abbr -a gs 'git status --short --branch'
abbr -a gss 'git status'
abbr -a ga 'git add -p'
abbr -a gah 'git stash; and git pull --rebase; and git stash pop'
abbr -a gc 'git commit'
abbr -a gca 'git commit --amend'
abbr -a gcm 'git commit -m'
abbr -a gb 'git branch'
abbr -a gbl 'git branch -l'
abbr -a gp 'git pull'
abbr -a gpsh 'git push'
abbr -a gpnb 'git push --set-upstream origin $(git current-branch)'
abbr -a gtr 'git tr'
abbr -a glg 'git log --oneline'

abbr -a dow 'cd $HOME/Downloads; eza -l'
abbr -a home 'cd $HOME; eza -l'
abbr -a repo 'cd $HOME/repo; eza -l'

abbr -a du 'du -h'
abbr -a du0 'du -sh * | sort -hr'
abbr -a du1 'du -hxd 1 | sort -hr'

abbr -a rsync 'rsync -v'
abbr -a procs 'ps aux | grep $USER'
abbr -a ports 'netstat -tulna'

abbr -a tm 'tmux'
abbr -a upd 'sudo apt update && sudo apt upgrade -y'

abbr -a c clear
abbr -a cp 'cp -v'
abbr -a mv 'mv -v'
abbr -a rm 'rm -v'

if status --is-interactive
	switch $TERM
		case 'linux'
			:
		case '*'
			if ! set -q TMUX
				exec tmux set-option -g default-shell (which fish) ';' new-session
			end
	end
end

if command -v eza > /dev/null
	abbr -a l 'eza -l'
	abbr -a ll 'eza -l'
	abbr -a ls 'eza -l'
	abbr -a la 'eza -la'
else
	abbr -a l 'ls -l'
	abbr -a ll 'ls -l'
	abbr -a la 'ls -la'
end

# Type d to move up to top parent dir which is a repository
function d
	while test $PWD != "/"
		if test -d .git
			break
		end
		cd ..
	end
end


# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
setenv FZF_DEFAULT_OPTS '--height 20%'

function fish_greeting
    # minimal two-color theme for dark bg (#181818)
    set -l c_sep    (set_color "#181818")  # separator color (subtle)
    set -l c_label (set_color blue)   # label (IP:, Disk:, RAM:, CPU:, GPU:)
    set -l c_value  (set_color brblack)  # separator color (subtle)
    set -l c_reset  (set_color normal)

    # newline before the status line
    echo

    # --- IP (first non-loopback IPv4) ---
    set -l ip (ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2; exit}' | cut -d/ -f1)
    if test -z "$ip"
        set ip "no-ip"
    end

    # --- Disk (usedGi totalGi percent) ---
    set disk_total (df -BG / | awk 'NR==2 {gsub("G","",$2); print $2}')
    set disk_used  (df -BG / | awk 'NR==2 {gsub("G","",$3); print $3}')
    set disk_pct   (df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    # --- RAM (usedGi totalGi percent) ---
    set mem_total (free -b | awk '/Mem:/ {printf "%.1f", $2/1024/1024/1024}')
    set mem_used  (free -b | awk '/Mem:/ {printf "%.1f", $3/1024/1024/1024}')
    set mem_pct   (free -b | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

    # --- CPU model (short, trimmed) ---
    set -l cpu (awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^ *//; s/ *$//')

    # --- GPU (nvidia-smi preferred, fallback to lspci) ---
    set gpu "None"
    if command -qs nvidia-smi
	set gpu (nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
    else if command -qs lspci
	set gpu (lspci | grep -iE 'vga|3d|display' | head -n1 | sed 's/.*controller: //')
    end

    printf "%sIP:%s %s %s| %sDisk:%s %sGi/%sGi (%s%%) %s| %sRAM:%s %sGi/%sGi (%s%%) %s| %sCPU:%s %s %s| %sGPU: %s%s%s\n" \
        $c_label $c_value $ip $c_sep \
    	$c_label $c_value $disk_used $disk_total $disk_pct $c_sep \
    	$c_label $c_value $mem_used $mem_total $mem_pct $c_sep \
    	$c_label $c_value "$cpu" $c_sep \
    	$c_label $c_value "$gpu" $c_reset
end


function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (command -q hostname; and hostname; or hostnamectl hostname)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end
