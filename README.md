# 🔴 RED TEAM KEYBOX

Magisk / KernelSU-Next модуль для автоматической установки и обновления **Keybox** и **target.txt** для [TEESimulator-RS](https://github.com/Enginex0/TEESimulator-RS), с удобным WebUI для управления всеми функциями без консоли.

---

## 📋 Возможности

- ⚡ **Установка Keybox** — автоматическая загрузка и подстановка актуального keybox устройства
- 📄 **Настройка target.txt** — список приложений, для которых применяется keybox
- 🛑 **Очистка Google-сервисов** — сброс кэша и данных GMS одной кнопкой
- 🔒 **PIF (Play Integrity Fix)** — обновление fingerprint устройства
- 🛡️ **Security Patch Date** — установка актуальной даты патча безопасности
- 🔧 **Фикс обнаружения Recovery** — скрывает следы кастомного recovery
- 🔐 **Verified Boothash** — корректный хэш загрузки для верификации boot
- 🔄 **Автономный мониторинг Keybox** — фоновый демон сам проверяет и обновляет keybox по расписанию, без ручного вмешательства

## 🖥 WebUI

Модуль поставляется с полноценным веб-интерфейсом (открывается прямо из Magisk/KernelSU Manager):

| Раздел | Что внутри |
|---|---|
| 🏠 Главная | версия модуля и статус, дата/время, информация об устройстве (модель, Android, ядро, реализация root) |
| 📋 Меню | основные функции: Keybox, GMS, PIF, Security |
| ⚙️ Меню + | дополнительные исправления и управление мониторингом |
| 🔧 Настройки | язык, тема оформления, формат времени, ссылки на обновления |

**Оформление:**
- 🎨 Тёмная / светлая / авто тема + 6 цветовых пресетов
- 🌑 Честный AMOLED-чёрный в тёмном режиме — экономит батарею на OLED-экранах
- 🌐 Интерфейс переведён на 12 языков
- 📜 История выполнения скриптов — доступна по тапу на карточку версии

---

## 📦 Установка

1. Скачайте последний `.zip` со страницы [Releases](https://github.com/redteam-git/RED-TEAM-KEYBOX/releases)
2. Установите через Magisk Manager / KernelSU Manager → **Модули → Установить из хранилища**
3. Перезагрузите устройство
4. Откройте WebUI модуля и настройте нужные функции

## ✅ Требования

- Root: **Magisk** или **KernelSU / KernelSU-Next**
- Установленный [TEESimulator-RS](https://github.com/Enginex0/TEESimulator-RS)
- Android 10+

---

## 🔄 История изменений

Актуальный список изменений — на странице [Releases](https://github.com/redteam-git/RED-TEAM-KEYBOX/releases).

**Кратко о последнем крупном обновлении (v4.0):** полный переход с одиночного скрипта на WebUI — отдельные функции с описаниями, автономный мониторинг keybox, мультиязычность, AMOLED-тема и информация об устройстве на главном экране.

---

## 👥 Разработчики

- **Nikita** — [@fhwjww](https://t.me/fhwjww) — Founder & Module Developer
- **Dmitry** — [@DperehodnikD](https://t.me/DperehodnikD) — Founder & Module Developer

## 📲 Сообщество и поддержка

- Telegram-канал: [t.me/REDTEAMMANAGERR](https://t.me/REDTEAMMODULE)
- Баги и предложения: [Issues](https://github.com/redteam-git/RED-TEAM-KEYBOX/issues)

---

<p align="center">Done by <b>RED TEAM</b> 🔴</p>
