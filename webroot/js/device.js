window.refreshDeviceInfo = function() {
  const scriptPath = "/data/adb/modules/red_team/webroot/common/device-info.sh";
  console.log("🔧 Обновление информации об устройстве...");

  if (typeof ksu === "object" && typeof ksu.exec === "function") {
    const cbId = `cb_${Date.now()}`;
    window[cbId] = (code, out, err) => {
      delete window[cbId];
      console.log("📤 Код:", code);
      console.log("📤 Вывод:", out);

      if (code === 0) {
        try {
          const data = JSON.parse(out.trim());
          document.getElementById("device-model").innerText = data.model || "-";
          document.getElementById("android-version").innerText = data.android || "-";
          document.getElementById("kernel-version").innerText = data.kernel || "-";
          document.getElementById("root-type").innerText = data.root || "-";
          
          
          updateStatusOnline();
          
          if (typeof showToast === "function") {
            showToast("✅ Информация обновлена!", "success");
          }
        } catch (e) {
          console.error("Ошибка парсинга JSON:", e);
          if (typeof showToast === "function") {
            showToast("❌ Ошибка парсинга данных", "error");
          }
        }
      } else {
        if (typeof showToast === "function") {
          showToast(`❌ Ошибка: ${err || "код " + code}`, "error");
        }
      }
    };
    ksu.exec(`sh '${scriptPath}'`, "{}", cbId);
  } else {
    console.error("❌ ksu.exec недоступен!");
    if (typeof showToast === "function") {
      showToast("❌ ksu.exec недоступен", "error");
    }
  }
};



function updateStatusOnline() {
  const statusText = document.getElementById("status-bar-text");

  if (!statusText) return;

  
  if (navigator.onLine) {
    statusText.classList.remove("offline");
    statusText.classList.add("online");
    statusText.textContent = "Онлайн";
    statusText.setAttribute("data-i18n", "home_status_online");
  } else {
    statusText.classList.remove("online");
    statusText.classList.add("offline");
    statusText.textContent = "Офлайн";
    statusText.setAttribute("data-i18n", "home_status_offline");
  }
}



window.openUrl = function(url) {
  if (typeof ksu === "object" && typeof ksu.exec === "function") {
    const cbId = `cb_${Date.now()}`;
    window[cbId] = () => delete window[cbId];
    ksu.exec(`am start -a android.intent.action.VIEW -d '${url}'`, "{}", cbId);
  } else {
    window.open(url, "_blank");
  }
};



window.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    window.refreshDeviceInfo();
  }, 1000);
});