#!/bin/sh

gitignores=$(fd -IH '^\.gitignore$' "$@")

for path in $gitignores
do
  cat $path | while read -r ignore
  do
    # A line starting with # serves as a comment.
    if [[ $ignore =~ ^# ]]; then
      continue
    fi

    # Trim spaces
    ignore=$(echo $ignore | sed -e 's/^[[:space:]]*//')

    # Ignore empty lines
    if [[ -z "$ignore" ]]; then
      continue
    fi

    # An optional prefix "!" which negates the pattern.
    if [[ $ignore == !* ]]; then
      ignore=$(echo $ignore | sed -e 's#^!##')
      include=true
    else
      include=false
    fi

    pattern="$ignore"
    root=$(dirname $path | sed -e "s#^$@##")

    # A separator before the end of the pattern makes it absolute
    if [[ $(echo $ignore | sed -e 's#/$##') =~ / ]]; then
      pattern="$root/$(echo $pattern | sed -e 's#^/##')"
    else
      # Mimic relative search by making an absolute WRT to current directory,
      # preceded by a recursive glob `**`
      pattern="$root/**/$pattern"
    fi

    # A separator at the end only matches directories
    if [[ $ignore =~ /$ ]]; then
      # rclone only matches files, so we need to add `**` to match a directory
      pattern="$pattern**"
    fi

    if [[ $include = true ]]; then
      pattern="+ $pattern"
    else
      pattern="- $pattern"
    fi

    # A separator at the end only matches directories.  By de
    # The gitignore format matches both files and directories, whereas rclone
    # only matches files.  Therefore, every pattern must by expressed as both
    # `pattern` and `pattern/**`, EXCEPT patterns that end with a `/`, which
    # should only match directories, and therefore only appear as `pattern/**`

    # If the pattern doesn't end with `/`, include the file variant:
    if [[ $ignore =~ [^/]$ ]]; then
      echo "$pattern"
    fi
    # In any case, include the directory variant:
    echo "$(echo $pattern | sed -e 's#/$##')/**"
  done
done
