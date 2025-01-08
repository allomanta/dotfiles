ZJ_SESSIONS=$(zellij list-sessions -s)
NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)

if [ "{$ZELLIJ}" ] && [ -z "${ZELLIJ_SESSION_NAME}" ]; then
  echo -ne "Active Zellij sessions :\n"
  for i in $(echo "${ZJ_SESSIONS}"); do echo -ne "*${i}\n"; done
  echo -ne '\n'
  read REPLY\?"New zellij session [Y/n] ? "
  if [ "${REPLY}" = "n" ]; then
    if [ "${NO_SESSIONS}" -ge 1 ]; then
      zellij attach \
      "$(echo "${ZJ_SESSIONS}" | fzf)"
    fi
  else
    read SESS\?"Session name : "
    zellij attach -c "${SESS}"
  fi
fi
