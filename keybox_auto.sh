#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"
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
            # Гарантированная очистка временных файлов при совпадении
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
    
    # Финальная очистка всех временных артефактов
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
