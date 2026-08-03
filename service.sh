#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"
AUTORUN_SCRIPT="$MODDIR/autorun.sh"
KEY_SCRIPT="$MODDIR/keybox_auto.sh"

if [ ! -f "$KEY_SCRIPT" ] && [ -f "/data/adb/modules/red_team/keybox_auto.sh" ]; then
    KEY_SCRIPT="/data/adb/modules/red_team/keybox_auto.sh"
fi
[ -f "$KEY_SCRIPT" ] && chmod 755 "$KEY_SCRIPT" 2>/dev/null

if [ ! -f "$AUTORUN_SCRIPT" ] && [ -f "/data/adb/modules/red_team/autorun.sh" ]; then
    AUTORUN_SCRIPT="/data/adb/modules/red_team/autorun.sh"
fi
[ -f "$AUTORUN_SCRIPT" ] && chmod 755 "$AUTORUN_SCRIPT" 2>/dev/null

# Первичное обновление keybox в фоне
if [ -f "$KEY_SCRIPT" ]; then
    (
        sleep 45
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    ) &
fi

# Запуск AUTORUN демона
if [ -f "$AUTORUN_SCRIPT" ]; then
    if [ -f "$MODDIR/autorun.pid" ]; then
        OLD_PID=$(cat "$MODDIR/autorun.pid" 2>/dev/null)
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            true
        else
            rm -f "$MODDIR/autorun.pid" 2>/dev/null
            nohup sh "$AUTORUN_SCRIPT" > /dev/null 2>&1 &
        fi
    else
        nohup sh "$AUTORUN_SCRIPT" > /dev/null 2>&1 &
    fi
fi

# Фоновый мониторинг keybox.xml (каждые 4 часа)
(
    while true; do
        if [ ! -f "/data/adb/tricky_store/keybox.xml" ]; then
            if [ -f "$KEY_SCRIPT" ]; then
                sh "$KEY_SCRIPT" --once > /dev/null 2>&1
            fi
        fi
        sleep 14400
    done
) &

# Первичная проверка целостности keybox.xml
if [ ! -f "/data/adb/tricky_store/keybox.xml" ]; then
    if [ -f "$KEY_SCRIPT" ]; then
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    fi
fi

# Проверка target.txt
if [ ! -f "/data/adb/tricky_store/target.txt" ] && [ -f "$MODPATH/target.txt" ]; then
    cp "$MODPATH/target.txt" "/data/adb/tricky_store/target.txt" 2>/dev/null
    chmod 644 "/data/adb/tricky_store/target.txt" 2>/dev/null
fi

exit 0
