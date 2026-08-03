#!/system/bin/sh
REPO="KOWX712/PlayIntegrityFix"
ZIP_PATH="/data/local/tmp/module_update_$$.zip"

echo "⏳ Запрос данных о последнем релизе $REPO..."

download_file() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -s -k -L -o "$output" "$url"
        if [ -f "$output" ] && [ "$(stat -c%s "$output" 2>/dev/null || echo 0)" -gt 10000 ]; then
            return 0
        fi
    fi

    if command -v wget >/dev/null 2>&1; then
        wget --no-check-certificate -O "$output" "$url"
        if [ -f "$output" ] && [ "$(stat -c%s "$output" 2>/dev/null || echo 0)" -gt 10000 ]; then
            return 0
        fi
    fi

    if toybox --help 2>&1 | grep -q "wget" || command -v toybox >/dev/null 2>&1; then
        toybox wget -O "$output" "$url"
        if [ -f "$output" ] && [ "$(stat -c%s "$output" 2>/dev/null || echo 0)" -gt 10000 ]; then
            return 0
        fi
    fi

    return 1
}

JSON_DATA=""
if command -v curl >/dev/null 2>&1; then
    JSON_DATA=$(curl -s -k "https://api.github.com/repos/$REPO/releases/latest")
elif command -v wget >/dev/null 2>&1; then
    JSON_DATA=$(wget --no-check-certificate -qO- "https://api.github.com/repos/$REPO/releases/latest")
elif command -v toybox >/dev/null 2>&1; then
    JSON_DATA=$(toybox wget -qO- "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null)
fi

URL=$(echo "$JSON_DATA" | grep -o '"browser_download_url": *"[^"]*"' | grep -i "\.zip" | head -n 1 | cut -d'"' -f4)

if [ -z "$URL" ]; then
    echo "❌ Ошибка: не удалось найти .zip файл релиза!"
    exit 1
fi

echo "✅ Найдена ссылка: $URL"
echo "📥 Скачивание архива (может занять время)..."

download_file "$URL" "$ZIP_PATH"

if [ ! -f "$ZIP_PATH" ]; then
    echo "❌ Ошибка: файл не скачался ни одним из способов!"
    exit 1
fi

FILE_SIZE=$(stat -c%s "$ZIP_PATH" 2>/dev/null)
if [ -z "$FILE_SIZE" ] || [ "$FILE_SIZE" -lt 10000 ]; then
    echo "❌ Ошибка: архив пуст или повреждён!"
    rm -f "$ZIP_PATH"
    exit 1
fi

echo "📦 Размер архива: $FILE_SIZE байт"
echo "⚙️ Запуск установки модуля..."

if [ -f "/data/adb/ksud" ]; then
    echo "🟢 Обнаружен KernelSU. Устанавливаем..."
    /data/adb/ksud module install "$ZIP_PATH"
    STATUS=$?
elif [ -f "/data/apatch/apatch" ] || command -v apm >/dev/null 2>&1; then
    echo "🟢 Обнаружен APatch. Устанавливаем..."
    apm install "$ZIP_PATH"
    STATUS=$?
elif command -v magisk >/dev/null 2>&1; then
    echo "🟢 Обнаружен Magisk. Устанавливаем..."
    magisk --install-module "$ZIP_PATH"
    STATUS=$?
else
    echo "❌ Ошибка: Установщик модулей не найден!"
    rm -f "$ZIP_PATH"
    exit 1
fi

if [ $STATUS -eq 0 ]; then
    echo "🎉 Установка Play Integrity Fix успешно завершена!"
    echo "⚠️ Обязательно перезагрузите устройство."
else
    echo "❌ Произошла ошибка при установке. Код: $STATUS"
fi

rm -f "$ZIP_PATH"
