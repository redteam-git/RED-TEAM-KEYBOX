#!/system/bin/sh

if [ -d "/data/adb/modules_update/red_team" ]; then
  BASE_PATH="/data/adb/modules_update/red_team"
else
  BASE_PATH="/data/adb/modules/red_team"
fi

INFO_PATH="$BASE_PATH/webroot/json/device-info.json"

android_ver=$(getprop ro.build.version.release 2>/dev/null || echo "none")
kernel_ver=$(uname -r 2>/dev/null || echo "none")
device_model_raw=$(getprop ro.product.model 2>/dev/null)
device_manufacturer=$(getprop ro.product.manufacturer 2>/dev/null)

if [ -n "$device_manufacturer" ] && [ -n "$device_model_raw" ]; then
  device_model="$device_manufacturer $device_model_raw"
elif [ -n "$device_model_raw" ]; then
  device_model="$device_model_raw"
else
  device_model="Unknown"
fi

if [ -d "/data/adb/magisk" ] && [ -f "/data/adb/magisk.db" ]; then
  root_type="Magisk"
elif [ -f "/data/apatch/apatch" ]; then
  root_type="APatch"
elif [ -d "/data/adb/ksu" ] && { [ -d "/data/adb/kpm" ] || [ -f "/data/adb/ksu/.dynamic_sign" ]; }; then
  root_type="SukiSU-Ultra"
elif [ -d "/data/adb/ksu" ] && { [ -f "/data/adb/ksud" ] || [ -f "/sys/module/kernelsu/parameters/expected_manager_size" ]; }; then
  root_type="KernelSU-Next"
elif [ -d "/data/adb/ksu" ]; then
  root_type="KernelSU"
else
  root_type="Unknown"
fi

cat <<EOF > "$INFO_PATH"
{
  "model": "$device_model",
  "android": "$android_ver",
  "kernel": "$kernel_ver",
  "root": "$root_type"
}
EOF

cat "$INFO_PATH"