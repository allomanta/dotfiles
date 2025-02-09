ZJ_SESSIONS=$(zellij list-sessions -s | grep -v "Tmp" )

if [ "{$ZELLIJ}" ] && [ -z "${ZELLIJ_SESSION_NAME}" ]; then
  echo ${ZJ_SESSIONS}| fzf --border --border-label "Choose/create Zellij session (blank for tmp)" --layout reverse --height 50% --print-query | { read INPUT; read SELECTION; }

  if [ -z "${INPUT}"]; then
    SESSION="Tmp-$(date +%s)"
  else
    SESSION=$SELECTION
  fi 

  zellij attach -c "${SESSION}"
fi
