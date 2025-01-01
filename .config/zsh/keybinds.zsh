### vim keybindings
source "$ZDOTDIR"/helix-mode/helix-mode.zsh

bindkey -M hxins "^R"  fzf-history-widget 
bindkey -M hxins "^T"  fzf-history-widget 
bindkey -M hxins "^[c" fzf-cd-widget
bindkey -M hxcmd "^R"  fzf-history-widget 
bindkey -M hxcmd "^T"  fzf-history-widget 
bindkey -M hxcmd "^[c" fzf-cd-widget

resume() {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
  }
zle -N resume
bindkey "^Z" resume

