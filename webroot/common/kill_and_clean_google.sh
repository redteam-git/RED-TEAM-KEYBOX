#!/system/bin/sh

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [KILL_GOOGLE] $1"
}

PKGS="com.android.vending"
log_message "Начало остановки и очистки"
echo "[*] Очистка Google Services..."

for pkg in $PKGS; do
    log_message "Обработка пакета: $pkg"
    
    if am force-stop "$pkg" >/dev/null 2>&1; then
        log_message "Успешная остановка: $pkg"
    else
        log_message "Ошибка остановки: $pkg"
    fi
    
    if pm clear "$pkg" >/dev/null 2>&1; then
        log_message "Успешная очистка данных: $pkg"
    else
        log_message "Ошибка очистки данных: $pkg"
    fi
done

log_message "Завершено"

echo ""
echo "========================================"
for i in $(seq 1 4); do
    echo "Done by RED TEAM"
done
echo "========================================"
echo ""

echo "✅ Google сервисы очищены!"
exit 0