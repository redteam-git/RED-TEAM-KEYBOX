#!/system/bin/sh

echo "=== Установка RED Keybox ==="

MODDIR="/data/adb/modules/red_team"
TARGET_DIR="/data/adb/tricky_store"

SOURCE_KEYBOX="$MODDIR/keybox.xml"
TARGET_KEYBOX="$TARGET_DIR/keybox.xml"
BACKUP_KEYBOX="$TARGET_DIR/keybox.xml.bak"

LOGS_DIR="/data/adb/red_team_logs"
mkdir -p "$LOGS_DIR" 2>/dev/null

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGS_DIR/keybox.log"
}

log_message "=== Установка Keybox ==="

echo "[*] Проверка директории TrickyStore..."

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    chmod 755 "$TARGET_DIR"
    chown 0:0 "$TARGET_DIR"
    echo "[OK] Директория создана: $TARGET_DIR"
    log_message "Создана директория $TARGET_DIR"
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

if [ -f "$SOURCE_KEYBOX_B64" ] && [ -s "$SOURCE_KEYBOX_B64" ]; then
    if [ -f "$TARGET_KEYBOX" ]; then
        cp "$TARGET_KEYBOX" "$BACKUP_KEYBOX"
        echo "[OK] Старый keybox.xml сохранён в keybox.xml.bak"
        log_message "Бэкап keybox.xml создан"
    fi
    
    base64 -d "$SOURCE_KEYBOX_B64" > "$TARGET_KEYBOX" 2>/dev/null
    
    rm -f "$SOURCE_KEYBOX_B64"
    
    chmod 644 "$TARGET_KEYBOX"
    chown 0:0 "$TARGET_KEYBOX"
    echo "[OK] Новый keybox.xml установлен"
    log_message "keybox.xml установлен (размер: $(wc -c < "$TARGET_KEYBOX") байт)"
else
    echo "[WARN] Не удалось скачать keybox"
    log_message "❌ Не удалось скачать keybox"
fi

echo ""
echo "========================================"
for i in $(seq 1 4); do
    echo "Done by RED TEAM"
done
echo "========================================"
echo ""

echo "✅ Keybox установлен!"
exit 0