#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"
LOGS_DIR="/data/adb/red_team_logs"

mkdir -p "$LOGS_DIR" 2>/dev/null

if [ ! -f "$LOGS_DIR/autopilot" ]; then
    touch "$LOGS_DIR/autopilot"
fi

if [ ! -f "$MODDIR/service.sh" ]; then
    exit 1
fi

chmod 755 "$MODDIR/service.sh" 2>/dev/null

(
    sleep 5
    nohup sh "$MODDIR/service.sh" > /dev/null 2>&1 &
) &

exit 0
