const LANG_PATH = "lang/";
const DEFAULT_LANG = "en";
let translations = {};
window.translations = translations;

const SUPPORTED_LANGUAGES = [
  "en", "af", "ar", "vi", "zh", "fr", "de", "pt", "it", "ja", "es", "ru", "be", "uk"
];

function getSystemLanguage() {
  const rawLang = navigator.language || navigator.userLanguage || DEFAULT_LANG;
  const sysLang = rawLang.substring(0, 2).toLowerCase();
  
  return SUPPORTED_LANGUAGES.includes(sysLang) ? sysLang : DEFAULT_LANG;
}

function t(key) {
  return window.translations?.[key] || key;
}

function tFormat(key, vars = {}) {
  let str = t(key);
  Object.keys(vars).forEach(k => {
    str = str.replace(`{${k}}`, vars[k]);
  });
  return str;
}

async function applyLanguage(langCode) {
  try {
    let fetchUrl = `${LANG_PATH}${langCode}.json?ts=${Date.now()}`;
    
    const res = await fetch(fetchUrl);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    
    const json = await res.json();
    translations = json;
    window.translations = json;

    document.querySelectorAll("[data-i18n]").forEach(el => {
      const key = el.getAttribute("data-i18n");
      if (translations[key]) {
        if (el.children.length > 0) {
          const hasHTMLContent = el.innerHTML.includes('<');
          if (hasHTMLContent) {
            el.innerHTML = translations[key];
          } else {
            const walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false);
            let textNodes = [];
            let textNode;
            while (textNode = walker.nextNode()) {
              if (textNode.nodeValue.trim()) textNodes.push(textNode);
            }
            if (textNodes.length > 0) {
              textNodes[0].nodeValue = translations[key];
              for (let i = 1; i < textNodes.length; i++) textNodes[i].remove();
            } else {
              el.appendChild(document.createTextNode(translations[key]));
            }
          }
        } else {
          el.innerText = translations[key];
        }
      }
    });

    const refreshBtn = document.getElementById("refresh-info-btn");
    if (refreshBtn && refreshBtn.getAttribute("data-i18n")) {
      const defaultKey = refreshBtn.getAttribute("data-i18n");
      refreshBtn.innerText = t(defaultKey);
    }

    document.documentElement.lang = langCode;

    if (typeof window.updateNetworkStatus === "function") {
      setTimeout(() => window.updateNetworkStatus(), 100);
    }

    document.dispatchEvent(new CustomEvent("languageChanged", {
      detail: { language: langCode, translations: translations }
    }));
  } catch (err) {
    console.error("Failed to load language:", err);
  }
}

function setupLanguageDropdown(currentLang) {
  const langBtn = document.getElementById("lang-btn");
  const langOptions = document.getElementById("lang-options");

  const activeItem = document.querySelector(`#lang-options li[data-lang='${currentLang}']`);
  if (langBtn && activeItem) langBtn.innerText = activeItem.innerText;

  langBtn?.addEventListener("click", (e) => {
    e.stopPropagation();
    langOptions?.classList.toggle("show");
  });

  document.addEventListener("click", (e) => {
    if (!langOptions?.contains(e.target) && e.target !== langBtn) {
      langOptions?.classList.remove("show");
    }
  });

  document.querySelectorAll("#lang-options li").forEach(item => {
    item.addEventListener("click", () => {
      const lang = item.getAttribute("data-lang");
      
      localStorage.setItem("selectedLanguage", lang);
      
      applyLanguage(lang);
      langOptions?.classList.remove("show");
      if (langBtn) langBtn.innerText = item.innerText;
    });
  });
}

document.addEventListener("DOMContentLoaded", async () => {
  let savedLang = localStorage.getItem("selectedLanguage");
  
  if (savedLang && !SUPPORTED_LANGUAGES.includes(savedLang)) {
      savedLang = null;
  }

  const targetLang = savedLang || getSystemLanguage();
  
  await applyLanguage(targetLang);
  setupLanguageDropdown(targetLang);
});
