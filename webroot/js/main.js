document.addEventListener("DOMContentLoaded", () => {
  const BASE_SCRIPT = "/data/adb/modules/red_team/webroot/common/";

  let toastTimer;
  const SCRIPT_HISTORY_KEY = "scriptHistoryLogs";

  function readHistory() {
    try {
      const parsed = JSON.parse(localStorage.getItem(SCRIPT_HISTORY_KEY) || "[]");
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  function writeHistory(items) {
    localStorage.setItem(SCRIPT_HISTORY_KEY, JSON.stringify(items.slice(0, 80)));
  }

  function addScriptHistory(scriptName, outputText) {
    const cleanOutput = (outputText || "").trim();
    if (!cleanOutput) return;

    const history = readHistory();
    history.unshift({
      script: scriptName,
      output: cleanOutput,
      time: new Date().toLocaleString(),
    });
    writeHistory(history);
  }

  function renderHistoryDialog() {
    const contentEl = document.getElementById("script-history-content");
    if (!contentEl) return;

    const history = readHistory();
    if (!history.length) {
      contentEl.textContent = "No script history";
      return;
    }

    contentEl.innerHTML = history.map(item => {
      const script = item.script || "script";
      const time = item.time || "";
      const output = (item.output || "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\n/g, "<br>");
      return `<div><strong>[${time}] ${script}</strong><br>${output}</div><hr>`;
    }).join("");
  }

  function openHistoryDialog() {
    const dialog = document.getElementById("script-history-dialog");
    const overlay = document.getElementById("script-history-overlay");
    if (!dialog || !overlay) return;

    renderHistoryDialog();
    overlay.classList.add("active");
    if (!dialog.open) dialog.showModal();
  }

  function closeHistoryDialog() {
    const dialog = document.getElementById("script-history-dialog");
    const overlay = document.getElementById("script-history-overlay");
    if (!dialog || !overlay) return;

    if (dialog.open) dialog.close();
    overlay.classList.remove("active");
  }

  function showToast(message, type = "info", duration = 3000) {
    const snackbar = document.getElementById("snackbar");
    if (!snackbar) return;

    snackbar.textContent = message;
    snackbar.className = `snackbar show ${type}`;

    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
      snackbar.classList.remove("show");
    }, duration);
  }

  function openScriptOutputDialog(scriptName, status) {
    const dialog = document.getElementById("script-output-dialog");
    const overlay = document.getElementById("script-output-overlay");
    const title = document.getElementById("script-output-title");
    const content = document.getElementById("script-output-content");
    const statusEl = document.getElementById("script-output-status");

    if (!dialog || !overlay || !title || !content || !statusEl) return;

    title.textContent = `📜 ${scriptName}`;
    content.textContent = `⏳ ${scriptName} запускается...\n`;
    statusEl.textContent = `⏱️ Статус: ${status}`;

    overlay.classList.add("active");
    if (!dialog.open) dialog.showModal();
  }

  function updateScriptOutputDialog(scriptName, code, output) {
    const content = document.getElementById("script-output-content");
    const statusEl = document.getElementById("script-output-status");

    if (!content || !statusEl) return;

    if (code === 0) {
      statusEl.textContent = `✅ Статус: Успешно завершён (код: ${code})`;
    } else if (code === -1) {
      statusEl.textContent = `❌ Статус: Ошибка выполнения`;
    } else {
      statusEl.textContent = `❌ Статус: Ошибка (код: ${code})`;
    }

    content.textContent = output || "✅ Выполнено без вывода";
  }

  function closeScriptOutputDialog() {
    const dialog = document.getElementById("script-output-dialog");
    const overlay = document.getElementById("script-output-overlay");

    if (dialog && dialog.open) dialog.close();
    if (overlay) overlay.classList.remove("active");
  }

  window.execScript = function(scriptName) {
    const fullPath = `${BASE_SCRIPT}${scriptName}`;
    openScriptOutputDialog(scriptName, "⏳ Выполняется...");

    if (typeof ksu === "object" && typeof ksu.exec === "function") {
      const logFile = `/data/local/tmp/red_team_${Date.now()}.log`;
      const exitFile = `${logFile}.exit`;
      const cbId = `cb_${Date.now()}`;

      // Запускаем скрипт в фоне, пишем лог в файл и сохраняем код выхода
      const command = `sh '${fullPath}' > '${logFile}' 2>&1; echo $? > '${exitFile}' &`;
      
      ksu.exec(command, "{}", cbId);
      window[cbId] = () => { delete window[cbId]; };

      // Легкий таймер обновления лога каждые 1 секунду без перегрузки
      let pollTimer = setInterval(() => {
        const readCbId = `read_${Date.now()}`;
        
        window[readCbId] = (code, out) => {
          delete window[readCbId];
          if (out) {
            const content = document.getElementById("script-output-content");
            if (content) {
              content.textContent = out;
              content.scrollTop = content.scrollHeight;
            }
          }
        };

        ksu.exec(`cat '${logFile}' 2>/dev/null`, "{}", readCbId);

        // Проверяем, завершился ли скрипт
        const checkCbId = `check_${Date.now()}`;
        window[checkCbId] = (code, out) => {
          delete window[checkCbId];
          if (out && out.trim() === "done") {
            clearInterval(pollTimer);

            
            const finalCbId = `final_${Date.now()}`;
            window[finalCbId] = (fCode, fOut) => {
              delete window[finalCbId];
              
              const lines = (fOut || "").trim().split("\n");
              const exitCode = parseInt(lines.pop()) || 0;
              const finalOutput = lines.join("\n") || "✅ Выполнено без вывода";
              
              updateScriptOutputDialog(scriptName, exitCode, finalOutput);
              addScriptHistory(scriptName, finalOutput);

              if (exitCode === 0) {
                showToast(`✅ ${scriptName} выполнен!`, "success");
              } else {
                showToast(`❌ Ошибка: код ${exitCode}`, "error");
              }

              
              ksu.exec(`rm -f '${logFile}' '${exitFile}'`, "{}", `clean_${Date.now()}`);
            };

            ksu.exec(`cat '${logFile}' 2>/dev/null; echo ""; cat '${exitFile}' 2>/dev/null`, "{}", finalCbId);
          }
        };

        ksu.exec(`if [ -f '${exitFile}' ]; then echo 'done'; fi`, "{}", checkCbId);

      }, 1000);

    } else {
      updateScriptOutputDialog(scriptName, -1, "❌ ksu.exec недоступен!");
      showToast("❌ ksu.exec недоступен", "error");
    }
  };

  document.querySelectorAll(".nav-btn").forEach(btn => {
    btn.addEventListener("click", function() {
      document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
      this.classList.add("active");
      
      const pageId = this.dataset.page;
      if (pageId) {
        document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
        const targetPage = document.getElementById(pageId);
        if (targetPage) {
          targetPage.classList.add("active");
        }
      }
      
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });

  const clockDateEl = document.getElementById("clock-date");
  const clockTimeEl = document.getElementById("clock-time");
  const clockFormatBtn = document.getElementById("clock-format-btn");
  const clockFormatOptions = document.getElementById("clock-format-options");
  const CLOCK_FORMAT_KEY = "clockFormat";

  function getClockFormat() {
    return localStorage.getItem(CLOCK_FORMAT_KEY) || "auto";
  }

  function getClockFormatLabel(format) {
    if (format === "24h") return "24-hour (00:00)";
    if (format === "12h") return "12-hour (AM/PM)";
    return "Auto (Device)";
  }

  function setupClockFormatDropdown() {
    if (!clockFormatBtn || !clockFormatOptions) return;

    const currentFormat = getClockFormat();
    clockFormatBtn.innerText = getClockFormatLabel(currentFormat);

    clockFormatBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      clockFormatOptions.classList.toggle("show");
    });

    document.addEventListener("click", (e) => {
      if (!clockFormatOptions.contains(e.target) && e.target !== clockFormatBtn) {
        clockFormatOptions.classList.remove("show");
      }
    });

    clockFormatOptions.querySelectorAll("li[data-format]").forEach(item => {
      item.addEventListener("click", () => {
        const format = item.dataset.format || "auto";
        localStorage.setItem(CLOCK_FORMAT_KEY, format);
        clockFormatBtn.innerText = getClockFormatLabel(format);
        clockFormatOptions.classList.remove("show");
        updateClock();
        showToast(`Clock format: ${getClockFormatLabel(format)}`, "success");
      });
    });
  }

  function updateClock() {
    const now = new Date();
    const format = getClockFormat();

    const formattedDate = new Intl.DateTimeFormat(undefined, {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    }).format(now);

    let formattedTime;
    if (format === "24h") {
      formattedTime = new Intl.DateTimeFormat(undefined, {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false,
      }).format(now);
    } else if (format === "12h") {
      formattedTime = new Intl.DateTimeFormat(undefined, {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: true,
      }).format(now);
    } else {
      formattedTime = now.toLocaleTimeString(undefined, {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });
    }

    if (clockDateEl) clockDateEl.textContent = formattedDate;
    if (clockTimeEl) clockTimeEl.textContent = formattedTime;
  }

  setupClockFormatDropdown();
  updateClock();
  setInterval(updateClock, 1000);

  const closeBtn = document.getElementById("script-output-close");
  const overlay = document.getElementById("script-output-overlay");
  const dialog = document.getElementById("script-output-dialog");

  if (closeBtn) {
    closeBtn.addEventListener("click", closeScriptOutputDialog);
  }
  if (overlay) {
    overlay.addEventListener("click", closeScriptOutputDialog);
  }
  if (dialog) {
    dialog.addEventListener("close", function() {
      if (overlay) overlay.classList.remove("active");
    });
  }

  const historyCard = document.getElementById("module-version-card");
  const historyDialog = document.getElementById("script-history-dialog");
  const historyOverlay = document.getElementById("script-history-overlay");
  const historyCloseBtn = document.getElementById("script-history-close");
  const historyClearBtn = document.getElementById("script-history-clear");

  historyCard?.addEventListener("click", openHistoryDialog);
  historyCloseBtn?.addEventListener("click", closeHistoryDialog);
  historyOverlay?.addEventListener("click", closeHistoryDialog);
  historyDialog?.addEventListener("close", () => historyOverlay?.classList.remove("active"));
  historyClearBtn?.addEventListener("click", () => {
    writeHistory([]);
    renderHistoryDialog();
  });

  async function updateOnlineStatus() {
    const statusBadge = document.querySelector(".status-badge");
    if (!statusBadge) return;

    statusBadge.textContent = "...";

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 3000);

      await fetch("https://1.1.1.1/cdn-cgi/trace", {
        method: "HEAD",
        mode: "no-cors",
        cache: "no-store",
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      statusBadge.classList.remove("offline");
      statusBadge.classList.add("online");
      statusBadge.textContent = t("home_status_online"); 
    } catch (e) {
      statusBadge.classList.remove("online");
      statusBadge.classList.add("offline");
      statusBadge.textContent = t("home_status_offline");
    }
  }

  updateOnlineStatus();

  window.addEventListener("online", updateOnlineStatus);
  window.addEventListener("offline", updateOnlineStatus);

  const refreshBtn = document.getElementById("refresh-info-btn");
  if (refreshBtn) {
    refreshBtn.addEventListener("click", updateOnlineStatus);
  }
});
