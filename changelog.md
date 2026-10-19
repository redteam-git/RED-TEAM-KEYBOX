🔴 **RED TEAM KEYBOX — глобальное обновление v5.0**[span_0](start_span)[span_0](end_span)

Модуль эволюционировал из простого установщика в полностью автономный, защищенный комбайн с интеллектуальным фоновым демоном и встроенным генератором отпечатков. Мы переписали архитектуру с нуля. Вот что нового:

---

### 🛡 Тотальная защита от взлома (Anti-Tamper)
Мы внедрили строгую систему безопасности для защиты целостности модуля на уровне установщика[span_1](start_span)[span_1](end_span)[span_2](start_span)[span_2](end_span). Установка немедленно прервется, если:
* Изменены авторы (`@fhwjww & @rootDima`) или ID модуля в `module.prop`[span_3](start_span)[span_3](end_span).
* Отсутствует цифровая подпись (`.signature_token`)[span_4](start_span)[span_4](end_span).
* Удалены или добавлены строки кода в скрипте установки (строгая проверка на 125 строк)[span_5](start_span)[span_5](end_span).
* Не совпадает SHA256-хэш нативного бинарника `redteam_guard`[span_6](start_span)[span_6](end_span).

### 🔄 Умный Автопилот (Фоновый демон)
Вам больше не нужно обновлять ключи вручную! Запущен интеллектуальный демон (`autorun.sh` и `keybox_auto.sh`), который работает полностью автономно в фоне[span_7](start_span)[span_7](end_span)[span_8](start_span)[span_8](end_span):
* Просыпается каждые 4 часа (`14400` секунд) и предварительно проверяет наличие сети[span_9](start_span)[span_9](end_span)[span_10](start_span)[span_10](end_span).
* Скачивает эталонный `keybox.xml` с нашего сервера и сравнивает его с текущим[span_11](start_span)[span_11](end_span).
* Обновляет ключи в TrickyStore и TEESimulator **только** если файл на сервере реально изменился[span_12](start_span)[span_12](end_span).
* Автоматически перезапускает (kill) службы `GMS`, `Play Store` и `GSF` на лету для моментального применения нового ключа без перезагрузки устройства[span_13](start_span)[span_13](end_span).

### 📱 Встроенный генератор Play Integrity Fix (PIF)
В модуль интегрирован мощный алгоритм динамической маскировки (`pif.prop generator`)[span_14](start_span)[span_14](end_span). 
* Скрипт сам подключается к серверам Google (Android Flash Tool) и находит самые свежие сборки Pixel Canary / Beta[span_15](start_span)[span_15](end_span).
* Динамически извлекает актуальную дату патча безопасности (`SECURITY_PATCH`) и генерирует уникальный, не забаненный отпечаток устройства[span_16](start_span)[span_16](end_span).
* Корректно подбирает `DEVICE_INITIAL_SDK_INT` для всех актуальных поколений Google Pixel (от `bluejay` до `yogi`)[span_17](start_span)[span_17](end_span).

### 🎯 Максимальный охват (target.txt)
Список защиты расширен до колоссальных масштабов. Мы скрываем Root и подменяем аттестацию для[span_18](start_span)[span_18](end_span):
* **Банков и Госсервисов:** Сбербанк, Тинькофф, Альфа-Банк, ВТБ, Госуслуги, Diia, Monobank, PrivatBank, Oschadbank и др[span_19](start_span)[span_19](end_span).
* **Криптобирж:** Binance, Bybit, MEXC, Kraken, Gate.io, KuCoin, OKX[span_20](start_span)[span_20](end_span).
* **Игр с жестким античитом:** PUBG Mobile, Call of Duty, Fortnite, Arena Breakout, Mobile Legends[span_21](start_span)[span_21](end_span).
* **Всей экосистемы Google:** Маркет, Сервисы, Кошелек, GSF[span_22](start_span)[span_22](end_span).
* Десятков системных оверлеев и приложений MIUI/Xiaomi/Oplus[span_23](start_span)[span_23](end_span).

### ⚙️ Автоматизация TEESimulator
Модуль теперь сам переносит и применяет эталонный конфигурационный файл `config.json` прямо в директорию TEESimulator (`/data/adb/teesim/`)[span_24](start_span)[span_24](end_span). Никакой ручной возни с настройками!

### 🧹 Идеальная чистота при удалении (Uninstall)
Специальный скрипт `uninstall.sh` гарантирует, что при удалении модуля будут корректно (через PID) завершены все фоновые демоны, а все временные файлы, кэши и логи (`/data/adb/red_team_logs`) будут стерты без следа[span_25](start_span)[span_25](end_span).

---

Done by **RED TEAM** 🔴
