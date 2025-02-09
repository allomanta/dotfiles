source "$HOME"/.zshenv 
source "$ZDOTDIR"/aliases.zsh
source "$ZDOTDIR"/widgets.zsh

autoload -Uz compinit; compinit
_comp_options+=(globdots) # With hidden files
source "$ZDOTDIR"/completions.zsh

# Options
export HISTFILE="$ZDOTDIR"/.zhistory    # History filepath
export HISTSIZE=100000                   # Maximum events for internal history
export SAVEHIST=100000                   # Maximum events in history file
setopt appendhistory
setopt auto_cd
setopt auto_pushd
setopt hist_expire_dups_first

source "$ZDOTDIR"/keybinds.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
eval "$(starship init zsh)" 
eval "$(zoxide init zsh --cmd cd)"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /home/steven/.scripts/zellij-sessions.zsh
