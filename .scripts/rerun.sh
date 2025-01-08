
#!/usr/bin/env bash

function execute() {
    clear
    echo "$@"
    eval "$@"
}

if [[ $1 == 1 ]]; then
    execute "${@:2}"
    inotifywait --quiet --recursive --monitor --event modify --format "%w%f" . \
    | while read change; do
        execute "${@:2}"
    done
else
    execute "$@"
    inotifywait --quiet --monitor --event modify --format "%w%f" . \
    | while read change; do
        execute "$@"
    done
fi

