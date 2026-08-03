#!/system/bin/sh

echo "=== Установка target.txt ==="

MODDIR="/data/adb/modules/red_team"
TARGET_DIR="/data/adb/tricky_store"

SOURCE_TARGET="$MODDIR/target.txt"
TARGET_TARGET="$TARGET_DIR/target.txt"
BACKUP_TARGET="$TARGET_DIR/target.txt.bak"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    chmod 755 "$TARGET_DIR"
    chown 0:0 "$TARGET_DIR"
    echo "[OK] Директория создана"
fi

if [ -f "$SOURCE_TARGET" ]; then
    if [ -f "$TARGET_TARGET" ]; then
        cp "$TARGET_TARGET" "$BACKUP_TARGET"
        echo "[OK] Старый target.txt сохранён"
    fi

    cp "$SOURCE_TARGET" "$TARGET_TARGET"
    chmod 644 "$TARGET_TARGET"
    chown 0:0 "$TARGET_TARGET"
    echo "[OK] Новый target.txt установлен"
else
    echo "[WARN] target.txt не найден"
fi

echo ""
echo "========================================"
echo "Done by RED TEAM"
echo "========================================"
echo ""

echo "✅ target.txt установлен!"
exit 0