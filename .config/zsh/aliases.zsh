alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
alias lazydots="lazygit --git-dir=$HOME/.dotfiles.git --work-tree=$HOME"

alias update-packages='paru -Syu'
alias errors='journalctl -p 3 -xb'
alias please='sudo $(fc -ln -1)'

alias py='python'
alias ipy='ipython'
alias helix='hx'

alias murderbot='ssh -p 3141 steven@local.lageveen.co'
alias mtmurder='sshfs -o reconnect,ServerAliveInterval=5,ServerAliveCountMax=3 -p 3141 steven@local.lageveen.co:. ~/Murderbot'

alias rerun="$HOME/.scripts/rerun.sh"

alias rga-fzf='with-env {FZF_DEFAULT_OPTS: "--ansi"} {rga-fzf}'

alias ls='exa -l --git --icons'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='gio trash'

alias dush='du -sh * | sort -hr'

alias pacman-installed=$'pacman -Qq | fzf --preview \'pacman -Qil {}\' --layout=reverse --bind \'enter:execute(pacman -Qil {} | less)\''
