for f in 0 1 2 3; do
  p=/sys/bus/pci/devices/0000:65:00.$f
  [ -e "$p" ] || continue
  echo "== $p =="
  cat "$p/power/control" 2>/dev/null
  cat "$p/power/runtime_status" 2>/dev/null
  cat "$p/class" 2>/dev/null
  cat "$p/power_state"
done

cat /proc/driver/nvidia/gpus/0000:65:00.0/power
cat /proc/driver/nvidia/params | grep -i DynamicPowerManagement
