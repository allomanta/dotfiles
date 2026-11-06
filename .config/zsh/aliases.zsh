# `dotfiles add <path>` also allowlists paths blocked by the catch-all rules in info/exclude
dotfiles() {
    local git=(/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME)
    local exclude=$HOME/.dotfiles.git/info/exclude
    local arg abs rel top entry rule

    if [[ $1 == add ]]; then
        for arg in "${@:2}"; do
            [[ $arg == -* ]] && continue
            abs=${arg:a}
            [[ $abs == $HOME/* && -e $abs ]] || continue
            rel=${abs#$HOME/}

            # Only act on the allowlist catch-alls; other ignores (*.bak, ...) stay ignored
            rule=$("${git[@]}" -C $HOME check-ignore -v --no-index -- $rel 2>/dev/null | cut -f1)
            [[ $rule == *:/\* || $rule == *:/.config/\* ]] || continue

            if [[ $rel == .config/* ]]; then
                top=.config/${${rel#.config/}%%/*}
            else
                top=${rel%%/*}
            fi
            entry="!/$top"
            [[ -d $HOME/$top ]] && entry+=/

            if ! grep -qxF -- $entry $exclude; then
                print -r -- $entry >> $exclude
                print "allowlisted $entry"
            fi
        done
    fi

    "${git[@]}" "$@"
}
alias lazydots="lazygit --git-dir=$HOME/.dotfiles.git --work-tree=$HOME"

alias update-packages='paru -Syu'
alias errors='journalctl -p 3 -xb'
alias please='sudo $(fc -ln -1)'

alias py='python'
alias ipy='ipython'
alias hx='TMUX=1 hx'
alias helix='hx'

alias murderbot='ssh -p 3141 steven@local.lageveen.co'
alias mtmurder='sshfs -o reconnect,ServerAliveInterval=5,ServerAliveCountMax=3 -p 3141 steven@local.lageveen.co:. ~/Murderbot'
alias umtmurder='fusermount3 -u ~/Murderbot'

alias rerun="$HOME/.scripts/rerun.sh"

alias rga-fzf='with-env {FZF_DEFAULT_OPTS: "--ansi"} {rga-fzf}'

alias ls='eza -l --git --icons --hyperlink --group-directories-first -h -o --no-permissions'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='gio trash'

alias dush='du -sh * | sort -hr'

alias zl-attach="source $HOME/.scripts/zellij-sessions.sh"

alias pacman-installed=$'pacman -Qq | fzf --preview \'pacman -Qil {}\' --layout=reverse --bind \'enter:execute(pacman -Qil {} | less)\''

nav() { 
    target=$(yazi --chooser-file=/dev/stdout)
    
    if [ -d "$target" ] || [ -z "$target" ]; then
        builtin cd "$target"
    else
        builtin cd "${target%/*}"
    fi
}


ngpuenv() {
  unset GSK_RENDERER
  unset __EGL_VENDOR_LIBRARY_FILENAMES
  unset __GLX_VENDOR_LIBRARY_NAME
  unset __NV_PRIME_RENDER_OFFLOAD
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only
}

acgpuenv() {
  export GSK_RENDERER=cairo
  export __NV_PRIME_RENDER_OFFLOAD=0
  export __GLX_VENDOR_LIBRARY_NAME=mesa
  export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
  unset __VK_LAYER_NV_optimus
}
