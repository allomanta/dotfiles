grid_size=3

##Utility functions

grid_max=$(($grid_size - 1))

function cycle() {
    echo $((($1 + $grid_size) % $grid_size))
}

##Get active workspace, and translate to rows and cols

active_ws=$(hyprctl monitors | grep "focused: yes" -B 10 | grep "active workspace" | awk -F': ' '{print $2}' | cut -d' ' -f1)
row=$((($active_ws - 1) / $grid_size))
col=$((($active_ws - 1) % $grid_size))

echo "$row : $col"

##Apply transformation
## change "cycle" to "clamp" to change the behavior

case $1 in
"up") row=$(cycle $(($row - 1))) ;;
"down") row=$(cycle $(($row + 1))) ;;
"left") col=$(cycle $(($col - 1))) ;;
*) col=$(cycle $(($col + 1))) ;;
esac

## translate col+row back to workspace number and apply

echo "$row : $col"
ws=$(($row * grid_size + $col + 1))
echo $ws
hyprctl dispatch workspace $ws
