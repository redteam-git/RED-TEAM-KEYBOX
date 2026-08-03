#!/system/bin/sh

echo "=== TrickyStore Keybox Installer ==="

MODPATH="${0%/*}"
MODDIR="/data/adb/modules/red_team"

SOURCE_KEYBOX="$MODPATH/keybox.xml"
TARGET_DIR="/data/adb/tricky_store"
TARGET_KEYBOX="$TARGET_DIR/keybox.xml"
BACKUP_KEYBOX="$TARGET_DIR/keybox.xml.bak"

echo "[*] Проверка директории TrickyStore..."

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    chmod 755 "$TARGET_DIR"
    chown 0:0 "$TARGET_DIR"
    echo "[OK] Директория создана: $TARGET_DIR"
else
    echo "[OK] Директория уже существует"
fi

echo "[*] Загрузка keybox..."

SOURCE_URL="https://raw.githubusercontent.com/redteam-git/RED-TEAM-KEYBOX/main/conf"
SOURCE_KEYBOX_B64="$TARGET_DIR/keybox.xml.b64"

curl -L "$SOURCE_URL" -o "$SOURCE_KEYBOX_B64" >/dev/null 2>&1
if [ ! -f "$SOURCE_KEYBOX_B64" ] || [ ! -s "$SOURCE_KEYBOX_B64" ]; then
    wget "$SOURCE_URL" -O "$SOURCE_KEYBOX_B64" >/dev/null 2>&1
fi
if [ ! -f "$SOURCE_KEYBOX_B64" ] || [ ! -s "$SOURCE_KEYBOX_B64" ]; then
    toybox wget "$SOURCE_URL" -O "$SOURCE_KEYBOX_B64" >/dev/null 2>&1
fi

if [ -f "$SOURCE_KEYBOX_B64" ]; then
    if [ -f "$TARGET_KEYBOX" ]; then
        cp "$TARGET_KEYBOX" "$BACKUP_KEYBOX"
        echo "[OK] Старый keybox.xml сохранён в keybox.xml.bak"
    fi
    
    base64 -d "$SOURCE_KEYBOX_B64" > "$TARGET_KEYBOX" 2>/dev/null
    rm -f "$SOURCE_KEYBOX_B64"
    
    chmod 644 "$TARGET_KEYBOX"
    chown 0:0 "$TARGET_KEYBOX"
    echo "[OK] Новый keybox.xml установлен"
else
    echo "[WARN] keybox.xml.b64 не найден, пропуск"
fi

echo "- Done!"

echo ""
echo "========================================"
for i in $(seq 1 4); do
    echo "Done by RED TEAM"
done
echo "========================================"
echo ""

echo "=== Установка завершена успешно ==="

ui_print " "
ui_print "--- Настройка автообновления keybox ---"

MODPATH="${0%/*}"
AUTORUN_SCRIPT="$MODPATH/autorun.sh"
KEY_SCRIPT="$MODPATH/keybox_auto.sh"
INTERVAL=14400


cat > "$KEY_SCRIPT" << 'EOF'


TARGET_DIR="/data/adb/tricky_store"
INTERVAL=14400
SOURCE_URL="https://raw.githubusercontent.com/redteam-git/RED-TEAM-KEYBOX/main/conf"

check_network() {
    if command -v ping >/dev/null 2>&1; then
        ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -s --connect-timeout 3 https://raw.githubusercontent.com >/dev/null 2>&1 && return 0
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -q --spider --timeout=3 https://raw.githubusercontent.com 2>/dev/null && return 0
    fi
    return 1
}

update_keybox() {
    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
        chmod 755 "$TARGET_DIR"
        chown 0:0 "$TARGET_DIR"
    fi
    
    if ! check_network; then
        return 1
    fi
    
    TEMP_FILE="$TARGET_DIR/keybox.xml.temp"
    DECODED_FILE="$TARGET_DIR/keybox.xml.decoded"
    DOUBLE_DECODED="$TARGET_DIR/keybox.xml.double"
    
    if command -v curl >/dev/null 2>&1; then
        curl -L "$SOURCE_URL" -o "$TEMP_FILE" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget "$SOURCE_URL" -O "$TEMP_FILE" 2>/dev/null
    elif command -v toybox >/dev/null 2>&1; then
        toybox wget "$SOURCE_URL" -O "$TEMP_FILE" 2>/dev/null
    else
        rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
        return 1
    fi
    
    if [ ! -f "$TEMP_FILE" ] || [ ! -s "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
        return 1
    fi
    
    if command -v base64 >/dev/null 2>&1; then
        base64 -d "$TEMP_FILE" > "$DECODED_FILE" 2>/dev/null
        DECODE_RESULT=$?
    else
        rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
        return 1
    fi
    
    if [ $DECODE_RESULT -ne 0 ] || [ ! -s "$DECODED_FILE" ]; then
        rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
        return 1
    fi
    
    if ! head -c 100 "$DECODED_FILE" | grep -q "<?xml\|<Keybox"; then
        base64 -d "$DECODED_FILE" > "$DOUBLE_DECODED" 2>/dev/null
        if [ $? -eq 0 ] && [ -s "$DOUBLE_DECODED" ] && head -c 100 "$DOUBLE_DECODED" | grep -q "<?xml\|<Keybox"; then
            mv "$DOUBLE_DECODED" "$DECODED_FILE"
        fi
    fi
    
    if [ -f "$TARGET_DIR/keybox.xml" ]; then
        if cmp -s "$DECODED_FILE" "$TARGET_DIR/keybox.xml" 2>/dev/null; then
            rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
            return 0
        fi
    fi
    
    if [ -f "$TARGET_DIR/keybox.xml" ]; then
        cp "$TARGET_DIR/keybox.xml" "$TARGET_DIR/keybox.xml.bak"
    fi
    
    mv "$DECODED_FILE" "$TARGET_DIR/keybox.xml"
    chmod 644 "$TARGET_DIR/keybox.xml"
    chown 0:0 "$TARGET_DIR/keybox.xml"
    
    rm -f "$TEMP_FILE" "$DECODED_FILE" "$DOUBLE_DECODED"
    
    for pkg in com.android.vending com.google.android.gms com.google.android.gsf; do
        am force-stop "$pkg" 2>/dev/null
        for pid in $(pgrep -f "$pkg" 2>/dev/null); do
            kill -9 "$pid" 2>/dev/null
        done
    done
    
    return 0
}

main_loop() {
    update_keybox
    while true; do
        sleep $INTERVAL
        update_keybox
    done
}

case "$1" in
    --once)
        update_keybox
        ;;
    --daemon)
        main_loop
        ;;
    *)
        nohup $0 --daemon > /dev/null 2>&1 &
        ;;
esac
EOF

chmod 755 "$KEY_SCRIPT"
ui_print "✅ Создан скрипт автообновления: keybox_auto.sh"

# Создаем скрипт autorun.sh без логов
cat > "$AUTORUN_SCRIPT" << 'EOF'
#!/system/bin/sh

MODPATH="/data/adb/modules/red_team"
KEY_SCRIPT="$MODPATH/keybox_auto.sh"
PID_FILE="$MODPATH/autorun.pid"
CHECK_INTERVAL=14400

check_running() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            return 0
        else
            rm -f "$PID_FILE" 2>/dev/null
            return 1
        fi
    fi
    return 1
}

do_update() {
    if [ -f "$KEY_SCRIPT" ]; then
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    elif [ -f "/data/adb/modules/red_team/keybox_auto.sh" ]; then
        KEY_SCRIPT="/data/adb/modules/red_team/keybox_auto.sh"
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    fi
}

check_network() {
    if command -v ping >/dev/null 2>&1; then
        ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -s --connect-timeout 3 https://raw.githubusercontent.com >/dev/null 2>&1 && return 0
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -q --spider --timeout=3 https://raw.githubusercontent.com 2>/dev/null && return 0
    fi
    return 1
}

main_loop() {
    if check_running; then
        exit 1
    fi
    
    echo $$ > "$PID_FILE"
    do_update
    
    while true; do
        if [ ! -f "$KEY_SCRIPT" ]; then
            if [ -f "/data/adb/modules/red_team/keybox_auto.sh" ]; then
                KEY_SCRIPT="/data/adb/modules/red_team/keybox_auto.sh"
            else
                rm -f "$PID_FILE"
                exit 1
            fi
        fi
        
        sleep $CHECK_INTERVAL
        
        if check_network; then
            do_update
        fi
    done
}

stop_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null
            sleep 1
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
        rm -f "$PID_FILE" 2>/dev/null
    fi
}

case "$1" in
    --stop)
        stop_daemon
        ;;
    --status)
        check_running && echo "Running" || echo "Stopped"
        ;;
    --once)
        do_update
        ;;
    --restart)
        stop_daemon
        sleep 2
        main_loop
        ;;
    *)
        main_loop
        ;;
esac
EOF

chmod 755 "$AUTORUN_SCRIPT"
ui_print "✅ Создан скрипт AUTORUN: autorun.sh"

# Создаем service.sh без логов
cat > "$MODPATH/service.sh" << 'EOF'
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

if [ -f "$KEY_SCRIPT" ]; then
    (
        sleep 45
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    ) &
fi

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

if [ ! -f "/data/adb/tricky_store/keybox.xml" ]; then
    if [ -f "$KEY_SCRIPT" ]; then
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    fi
fi

if [ ! -f "/data/adb/tricky_store/target.txt" ] && [ -f "$MODPATH/target.txt" ]; then
    cp "$MODPATH/target.txt" "/data/adb/tricky_store/target.txt" 2>/dev/null
    chmod 644 "/data/adb/tricky_store/target.txt" 2>/dev/null
fi

exit 0
EOF

chmod 755 "$MODPATH/service.sh"
ui_print "✅ Создан service.sh"

# Создаем post-fs-data.sh без логов
cat > "$MODPATH/post-fs-data.sh" << 'EOF'
#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"

if [ -f "$MODDIR/service.sh" ]; then
    chmod 755 "$MODDIR/service.sh" 2>/dev/null
    (
        sleep 5
        nohup sh "$MODDIR/service.sh" > /dev/null 2>&1 &
    ) &
fi

exit 0
EOF

chmod 755 "$MODPATH/post-fs-data.sh"
ui_print "✅ Создан post-fs-data.sh"

# Создаем чистый uninstall.sh
cat > "$MODPATH/uninstall.sh" << 'EOF'
#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"

if [ -f "$MODDIR/autorun.pid" ]; then
    kill -TERM $(cat "$MODDIR/autorun.pid") 2>/dev/null
    sleep 1
    kill -9 $(cat "$MODDIR/autorun.pid") 2>/dev/null
fi

rm -rf /data/adb/red_team_logs
rm -f "$MODDIR/*.log"
rm -f "$MODDIR/*.pid"

ui_print "✅ Модуль red_team удалён, следы и логи очищены"

exit 0
EOF

chmod 755 "$MODPATH/uninstall.sh"
ui_print "✅ Создан uninstall.sh"

if [ -f "$MODPATH/module.prop" ]; then
    if ! grep -q "description=" "$MODPATH/module.prop"; then
        echo "description=Автоматическое обновление keybox (проверка каждые 4 часа)" >> "$MODPATH/module.prop"
    else
        sed -i 's/^description=.*/description=Автоматическое обновление keybox (проверка каждые 4 часа)/' "$MODPATH/module.prop"
    fi
    ui_print "✅ Обновлён module.prop"
fi

ui_print " "
ui_print "--- Первичное обновление keybox ---"
sh "$KEY_SCRIPT" --once

ui_print " "
ui_print "========================================"
ui_print "✅ Модуль установлен без создания логов!"
ui_print "📁 Путь модуля: /data/adb/modules/red_team/"
ui_print "⏱️  Проверка каждые 4 часа (14400 секунд)"
ui_print "========================================"
ui_print " "

rm -f "$MODPATH/keybox.xml" 2>/dev/null

exit 0
