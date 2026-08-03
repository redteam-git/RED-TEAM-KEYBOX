#!/system/bin/sh

LOGS_DIR="/data/adb/red_team_logs"
mkdir -p "$LOGS_DIR" 2>/dev/null

echo "=== Выключение мониторинга keybox ==="


if [ -f "$LOGS_DIR/autopilot" ]; then
    rm -f "$LOGS_DIR/autopilot"
    echo "✅ Автопилот отключён"
else
    echo "⚠️ Автопилот уже отключён"
fi

if [ -f "/data/adb/modules/red_team/autorun.pid" ]; then
    PID=$(cat /data/adb/modules/red_team/autorun.pid)
    kill -TERM "$PID" 2>/dev/null
    sleep 1
    if kill -0 "$PID" 2>/dev/null; then
        kill -9 "$PID" 2>/dev/null
    fi
    rm -f "/data/adb/modules/red_team/autorun.pid"
    echo "✅ Демон остановлен (PID: $PID)"
else
    echo "⚠️ Демон не запущен"
fi

echo ""
echo "========================================"
echo "Done by RED TEAM"
echo "========================================"
echo ""

echo "🔴 Мониторинг keybox ВЫКЛЮЧЁН!"
exit 0