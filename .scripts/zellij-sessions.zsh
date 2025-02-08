ZJ_SESSIONS=$(zellij list-sessions -s | grep -v "Tmp" )
# ZJ_SESSIONS=$(zellij list-sessions -n | grep -v "EXITED" | sed "s/\s\[[^]]*\]\s//g" )
NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)

if [ "{$ZELLIJ}" ] && [ -z "${ZELLIJ_SESSION_NAME}" ]; then
  echo -ne "Active Zellij sessions :\n\n"
  echo $ZJ_SESSIONS
  echo -ne '\n'

  if [ "${NO_SESSIONS}" -le 0 ]; then
    zellij attach \
    "$(echo "${ZJ_SESSIONS}" | fzf)"
  fi

  read REPLY\?"New zellij session [y/N] ? "

  if [ "${REPLY}" = "y" ]; then
    SESSION="Tmp-$(date +%s)"
    vared -p "Session name: " SESSION
    zellij attach -c "${SESSION}"
  else
    zellij attach \
    "$(echo "${ZJ_SESSIONS}" | fzf)"
  fi
fi
