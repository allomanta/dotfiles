test() {
  # region_highlight="0 6 fg=green memo=zsh-syntax-highlighting"
  # region_highlight=( "${region_highlight:#*memo=hm}" )
  region_highlight=(
    "${(@)region_highlight:#*memo=hm}"
    "2 10 bg=red memo=hm"
  )
  zle -R

  # echo "testing: $region_highlight"
  # echo "testing: $zle_highlight"
  # echo "testing: ${zle_highlight[(r)${entry}:*]-}"
}
zle -N test

