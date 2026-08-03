#!/system/bin/sh

LOGS_DIR="/data/adb/red_team_logs"
mkdir -p "$LOGS_DIR" 2>/dev/null

echo "=== Включение мониторинга keybox ==="


touch "$LOGS_DIR/autopilot"
echo "✅ Мониторинг включён (autopilot создан)"


if [ ! -f "/data/adb/modules/red_team/autorun.pid" ]; then
    echo "⚠️ Демон не запущен, запускаю..."
    nohup sh /data/adb/modules/red_team/service.sh > /dev/null 2>&1 &
    sleep 2
    if [ -f "/data/adb/modules/red_team/autorun.pid" ]; then
        echo "✅ Демон запущен (PID: $(cat /data/adb/modules/red_team/autorun.pid))"
    fi
else
    echo "✅ Демон уже запущен (PID: $(cat /data/adb/modules/red_team/autorun.pid))"
fi

echo ""
echo "========================================"
echo "Done by RED TEAM"
echo "========================================"
echo ""

echo "🟢 Мониторинг keybox ВКЛЮЧЁН!"
exit 0