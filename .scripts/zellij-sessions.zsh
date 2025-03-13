ZJ_SESSIONS=$(zellij list-sessions -s | grep -v "Tmp" )

if [ "{$ZELLIJ}" ] && [ -z "${ZELLIJ_SESSION_NAME}" ]; then
  echo ${ZJ_SESSIONS}| fzf --border --border-label "Choose/create Zellij session (esc for tmp, alt-enter for new)" --layout reverse --height 50% --bind 'alt-enter:print-query' | read INPUT

  if [ -z "${INPUT}" ]; then
    SESSION="Tmp-$(date +%s)"
  else
    SESSION=$INPUT
  fi 

  zellij attach -c "${SESSION}"
fi
