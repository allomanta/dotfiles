root="$(git rev-parse --show-toplevel 2>/dev/null)"
fd . "${root:-./}" -x printf "{}: \033[3m\033[38;5;103m{//}/\033[38;5;177m{/}\033[0m %s\n"