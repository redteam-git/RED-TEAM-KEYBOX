#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"
LOGS_DIR="/data/adb/red_team_logs"

echo "=== Статус мониторинга keybox ==="
echo ""

if [ -f "$LOGS_DIR/autopilot" ]; then
    echo "🟢 Автопилот: ВКЛЮЧЁН"
else
    echo "🔴 Автопилот: ВЫКЛЮЧЕН"
fi

if [ -f "$MODDIR/autorun.pid" ]; then
    PID=$(cat "$MODDIR/autorun.pid" 2>/dev/null)
    if kill -0 "$PID" 2>/dev/null; then
        echo "✅ Демон: ЗАПУЩЕН (PID: $PID)"
    else
        echo "❌ Демон: НЕ ЗАПУЩЕН (PID файл есть, но процесс мёртв)"
    fi
else
    echo "❌ Демон: НЕ ЗАПУЩЕН"
fi

if [ -f "/data/adb/tricky_store/keybox.xml" ]; then
    SIZE=$(wc -c < "/data/adb/tricky_store/keybox.xml")
    echo "📦 keybox.xml: СУЩЕСТВУЕТ ($SIZE байт)"
else
    echo "❌ keybox.xml: ОТСУТСТВУЕТ"
fi

INTERVAL=$(grep "^CHECK_INTERVAL=" "$MODDIR/autorun.sh" 2>/dev/null | cut -d'=' -f2)
if [ -n "$INTERVAL" ]; then
    HOURS=$((INTERVAL / 3600))
    echo "⏱️ Интервал: $INTERVAL секунд ($HOURS часа)"
fi

echo ""
echo "========================================"
echo "Done by RED TEAM"
echo "========================================"
echo ""

exit 0
