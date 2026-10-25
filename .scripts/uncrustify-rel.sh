#!/usr/bin/env bash
set -euo pipefail

file_arg="${1:-}"
abs_file="$(realpath -m "$file_arg")"
dir="$(dirname "$abs_file")"

cfg_dir="$dir"
while [[ "$cfg_dir" != "/" ]]; do
    if [[ -f "$cfg_dir/style.cfg" ]]; then
        break
    fi
    cfg_dir="$(dirname "$cfg_dir")"
done

if [[ ! -f "$cfg_dir/style.cfg" ]]; then
    cfg_dir="."
fi

cd "$cfg_dir"

exec uncrustify \
  -c "style.cfg" \
  -l CPP \
  -f - \
  -o -
