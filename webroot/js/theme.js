const THEME_MODE_KEY = "themeMode";
const THEME_PRESET_KEY = "themePreset";

const SNACKBAR_COLOR_KEYS = {
  info: "snackbarInfoColor",
  success: "snackbarSuccessColor",
  warning: "snackbarWarningColor",
  error: "snackbarErrorColor",
  text: "snackbarTextColor",
};

const SNACKBAR_DEFAULTS = {
  info: "#2196f3",
  success: "#43a047",
  warning: "#f9a825",
  error: "#e53935",
  text: "#ffffff",
};

const THEME_PRESETS = {
  red: {
    dark: {
      "--ui-bg": "#000000",
      "--ui-card-bg": "#1a0000",
      "--ui-card-border": "#8a3a3a",
      "--ui-pill-bg": "#ff3333",
      "--ui-pill-text": "#ffffff",
      "--ui-nav-active": "#ff5555",
      "--ui-nav-text": "#ffaaaa",
      "--ui-select-bg": "#2a0a0a",
      "--ui-select-border": "#aa4444",
      "--ui-select-panel": "#0a0000",
      "--ui-select-panel-border": "#7a3a3a"
    },
    light: {
      "--ui-bg": "#fdf2f2",
      "--ui-card-bg": "#ffffff",
      "--ui-card-border": "#f0c4c4",
      "--ui-pill-bg": "#dc2626",
      "--ui-pill-text": "#ffffff",
      "--ui-nav-active": "#b91c1c",
      "--ui-nav-text": "#7a1a1a",
      "--ui-select-bg": "#fce8e8",
      "--ui-select-border": "#e8b8b8",
      "--ui-select-panel": "#fdf5f5",
      "--ui-select-panel-border": "#f0d0d0"
    }
  },
  ocean: {
    dark: { "--ui-bg": "#000000", "--ui-card-bg": "#0a1a2a", "--ui-card-border": "#4a7aaa", "--ui-pill-bg": "#00d4ff", "--ui-pill-text": "#000000", "--ui-nav-active": "#00aadd", "--ui-nav-text": "#88ddff", "--ui-select-bg": "#0a2a4a", "--ui-select-border": "#6090cc", "--ui-select-panel": "#050a15", "--ui-select-panel-border": "#5a7aaa" },
    light:{ "--ui-bg": "#e9f2ff", "--ui-card-bg": "#f2f7ff", "--ui-card-border": "#c6d8ef", "--ui-pill-bg": "#0061a4", "--ui-pill-text": "#ffffff", "--ui-nav-active": "#0061a4", "--ui-nav-text": "#001d36", "--ui-select-bg": "#d1e4ff", "--ui-select-border": "#b2cbe9", "--ui-select-panel": "#e2eeff", "--ui-select-panel-border": "#c3d8f3" },
  },
  rose: {
    dark: { "--ui-bg": "#000000", "--ui-card-bg": "#1a0505", "--ui-card-border": "#aa5577", "--ui-pill-bg": "#ff8899", "--ui-pill-text": "#000000", "--ui-nav-active": "#ff5577", "--ui-nav-text": "#ffbbdd", "--ui-select-bg": "#2a0a15", "--ui-select-border": "#cc6688", "--ui-select-panel": "#0a0003", "--ui-select-panel-border": "#995577" },
    light:{ "--ui-bg": "#fff3f1", "--ui-card-bg": "#ffe8e4", "--ui-card-border": "#efc7c1", "--ui-pill-bg": "#bb1614", "--ui-pill-text": "#ffffff", "--ui-nav-active": "#bb1614", "--ui-nav-text": "#410001", "--ui-select-bg": "#ffdad5", "--ui-select-border": "#e4b7b1", "--ui-select-panel": "#ffe9e5", "--ui-select-panel-border": "#e8c1bc" },
  },
  forest: {
    dark: { "--ui-bg": "#000000", "--ui-card-bg": "#0a1a0a", "--ui-card-border": "#66bb55", "--ui-pill-bg": "#00ff00", "--ui-pill-text": "#000000", "--ui-nav-active": "#00dd00", "--ui-nav-text": "#88ff88", "--ui-select-bg": "#0a2a0a", "--ui-select-border": "#66cc55", "--ui-select-panel": "#050a05", "--ui-select-panel-border": "#559944" },
    light:{ "--ui-bg": "#eff9ef", "--ui-card-bg": "#f5fcf4", "--ui-card-border": "#cce3cd", "--ui-pill-bg": "#006e1c", "--ui-pill-text": "#ffffff", "--ui-nav-active": "#006e1c", "--ui-nav-text": "#002204", "--ui-select-bg": "#94f990", "--ui-select-border": "#77d274", "--ui-select-panel": "#def6dd", "--ui-select-panel-border": "#b8dfb7" },
  },
  sunset: {
    dark: { "--ui-bg": "#000000", "--ui-card-bg": "#1a0a00", "--ui-card-border": "#aa7744", "--ui-pill-bg": "#ffaa55", "--ui-pill-text": "#000000", "--ui-nav-active": "#ff9933", "--ui-nav-text": "#ffcc99", "--ui-select-bg": "#2a1a0a", "--ui-select-border": "#bb8866", "--ui-select-panel": "#0a0500", "--ui-select-panel-border": "#996644" },
    light:{ "--ui-bg": "#fff4ea", "--ui-card-bg": "#fff8f2", "--ui-card-border": "#ecd3bc", "--ui-pill-bg": "#8b5000", "--ui-pill-text": "#ffffff", "--ui-nav-active": "#8b5000", "--ui-nav-text": "#2c1600", "--ui-select-bg": "#ffdcbe", "--ui-select-border": "#e8bf98", "--ui-select-panel": "#ffeddc", "--ui-select-panel-border": "#edcdb0" },
  },
  violet: {
    dark: { "--ui-bg": "#000000", "--ui-card-bg": "#0a0515", "--ui-card-border": "#aa66dd", "--ui-pill-bg": "#dd66ff", "--ui-pill-text": "#000000", "--ui-nav-active": "#cc44ff", "--ui-nav-text": "#ff99ff", "--ui-select-bg": "#1a0a2a", "--ui-select-border": "#aa77cc", "--ui-select-panel": "#050003", "--ui-select-panel-border": "#886699" },
    light:{ "--ui-bg": "#f9ecff", "--ui-card-bg": "#fdf5ff", "--ui-card-border": "#e4cdee", "--ui-pill-bg": "#9a25ae", "--ui-pill-text": "#ffffff", "--ui-nav-active": "#9a25ae", "--ui-nav-text": "#35003f", "--ui-select-bg": "#ffd6fe", "--ui-select-border": "#e8b8e8", "--ui-select-panel": "#ffe9ff", "--ui-select-panel-border": "#eecbf1" },
  },
};

function hexToRgb(hex) {
  const h = hex.replace("#", "");
  const n = h.length === 3 ? h.split("").map(c => c + c).join("") : h;
  const int = parseInt(n, 16);
  return { r: (int >> 16) & 255, g: (int >> 8) & 255, b: int & 255 };
}
function rgbToHex({ r, g, b }) {
  return `#${[r, g, b].map(v => v.toString(16).padStart(2, "0")).join("")}`;
}
function mix(a, b, t) {
  const c1 = hexToRgb(a), c2 = hexToRgb(b);
  return rgbToHex({ r: Math.round(c1.r + (c2.r - c1.r) * t), g: Math.round(c1.g + (c2.g - c1.g) * t), b: Math.round(c1.b + (c2.b - c1.b) * t) });
}

function getStoredMode() { return localStorage.getItem(THEME_MODE_KEY) || "dark"; }
function getResolvedMode(mode) { return mode === "auto" ? (window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark") : (mode || "dark"); }
function getStoredPreset() {
  const preset = localStorage.getItem(THEME_PRESET_KEY) || "red";
  return THEME_PRESETS[preset] ? preset : "red";
}
function themeText(key, fallback) { return window.translations?.[key] || fallback; }
function modeLabel(mode) {
  if (mode === "auto") return themeText("theme_mode_auto", "Auto (System)");
  if (mode === "light") return themeText("theme_mode_light", "Light");
  return themeText("theme_mode_dark", "Dark");
}

function withDerived(colors, mode) {
  const base = colors["--ui-pill-bg"];
  const pillText = colors["--ui-pill-text"] || (mode === "light" ? "#ffffff" : "#000000");
  return {
    ...colors,
    "--ui-pill-bg-hover": mix(base, mode === "light" ? "#ffffff" : "#ffffff", 0.15),
    "--ui-pill-border": mix(base, mode === "light" ? "#ffffff" : "#ffffff", 0.25),
    "--ui-nav-text-active": "#ffffff",
    "--ui-pill-text": pillText,
  };
}

function applyColors(rawColors) {
  const root = document.documentElement;
  Object.entries(rawColors).forEach(([k, v]) => root.style.setProperty(k, v));
}

function applyThemeMode(mode) {
  const resolved = getResolvedMode(mode);
  document.documentElement.setAttribute("data-theme-mode", resolved);
  return resolved;
}

function applyThemePreset(presetName) {
  const mode = document.documentElement.getAttribute("data-theme-mode") || "dark";
  const preset = THEME_PRESETS[presetName] || THEME_PRESETS.red;
  applyColors(withDerived(preset[mode] || preset.dark, mode));
  document.querySelectorAll(".theme-preset-btn").forEach(btn => btn.classList.toggle("active", btn.dataset.themePreset === presetName));
}

function normalizeHex(value, fallback = "#2196f3") {
  const raw = (value || "").trim();
  const match = raw.match(/^#?[0-9a-fA-F]{6}$/);
  if (!match) return fallback;
  return raw.startsWith("#") ? raw.toLowerCase() : `#${raw.toLowerCase()}`;
}

function hexToRgbTuple(hex) {
  const n = normalizeHex(hex).replace("#", "");
  return {
    r: parseInt(n.slice(0, 2), 16),
    g: parseInt(n.slice(2, 4), 16),
    b: parseInt(n.slice(4, 6), 16),
  };
}

function rgbToHexTuple(r, g, b) {
  return `#${[r, g, b].map(v => Number(v).toString(16).padStart(2, "0")).join("")}`;
}

function setSnackbarColor(type, value) {
  const key = SNACKBAR_COLOR_KEYS[type];
  const normalized = normalizeHex(value, SNACKBAR_DEFAULTS[type]);
  localStorage.setItem(key, normalized);
  document.documentElement.style.setProperty(`--snackbar-${type}`, normalized);

  const input = document.getElementById(`snackbar-${type}-color`);
  const preview = document.getElementById(`snackbar-${type}-preview`);
  if (input) input.value = normalized;
  if (preview) preview.style.background = normalized;
  return normalized;
}

function applySnackbarColors() {
  Object.entries(SNACKBAR_COLOR_KEYS).forEach(([type, key]) => {
    const value = localStorage.getItem(key) || SNACKBAR_DEFAULTS[type];
    setSnackbarColor(type, value);
  });
}

function bindSnackbarColorInputs() {
  Object.keys(SNACKBAR_COLOR_KEYS).forEach(type => {
    const input = document.getElementById(`snackbar-${type}-color`);
    if (!input) return;

    input.addEventListener("change", () => setSnackbarColor(type, input.value));
    input.addEventListener("blur", () => setSnackbarColor(type, input.value));
  });
}

function bindSnackbarColorTool() {
  const target = document.getElementById("snackbar-color-target");
  const hexInput = document.getElementById("snackbar-color-tool-hex");
  const preview = document.getElementById("snackbar-color-tool-preview");
  const rangeR = document.getElementById("snackbar-color-r");
  const rangeG = document.getElementById("snackbar-color-g");
  const rangeB = document.getElementById("snackbar-color-b");
  const applyBtn = document.getElementById("snackbar-color-tool-apply");
  if (!target || !hexInput || !preview || !rangeR || !rangeG || !rangeB || !applyBtn) return;

  const syncFromHex = (hex) => {
    const rgb = hexToRgbTuple(hex);
    rangeR.value = rgb.r;
    rangeG.value = rgb.g;
    rangeB.value = rgb.b;
    preview.style.background = normalizeHex(hex);
    hexInput.value = normalizeHex(hex);
  };

  const syncFromTarget = () => {
    const type = target.value || "info";
    const input = document.getElementById(`snackbar-${type}-color`);
    syncFromHex(input?.value || SNACKBAR_DEFAULTS[type]);
  };

  const syncFromRanges = () => {
    const hex = rgbToHexTuple(rangeR.value, rangeG.value, rangeB.value);
    preview.style.background = hex;
    hexInput.value = hex;
  };

  target.addEventListener("change", syncFromTarget);
  [rangeR, rangeG, rangeB].forEach(range => range.addEventListener("input", syncFromRanges));
  hexInput.addEventListener("input", () => {
    if (/^#?[0-9a-fA-F]{6}$/.test(hexInput.value.trim())) {
      syncFromHex(hexInput.value);
    }
  });

  applyBtn.addEventListener("click", () => {
    const type = target.value || "info";
    const applied = setSnackbarColor(type, hexInput.value);
    syncFromHex(applied);
  });

  syncFromTarget();
}



window.applyThemePreset = function(presetName) {
  if (!presetName || !THEME_PRESETS[presetName]) return;
  localStorage.setItem(THEME_PRESET_KEY, presetName);
  applyThemePreset(presetName);
  if (typeof showToast === "function") {
    showToast(`Theme: ${presetName}`, "success");
  }
};

window.setThemeMode = function(mode) {
  if (!mode) return;
  localStorage.setItem(THEME_MODE_KEY, mode);
  const modeBtn = document.getElementById("theme-mode-btn");
  if (modeBtn) modeBtn.innerText = modeLabel(mode);
  applyThemeMode(mode);
  applyThemePreset(getStoredPreset());
  if (typeof showToast === "function") {
    showToast(`Mode: ${modeLabel(mode)}`, "success");
  }
};

window.addEventListener("DOMContentLoaded", () => {
  const modeBtn = document.getElementById("theme-mode-btn");
  const modeOptions = document.getElementById("theme-mode-options");

  const mode = getStoredMode();
  if (modeBtn) modeBtn.innerText = modeLabel(mode);
  applyThemeMode(mode);

  if (modeBtn) {
    modeBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      if (modeOptions) modeOptions.classList.toggle("show");
    });
  }

  if (modeOptions) {
    modeOptions.querySelectorAll("li[data-mode]").forEach(item => {
      item.addEventListener("click", () => {
        const m = item.dataset.mode || "dark";
        localStorage.setItem(THEME_MODE_KEY, m);
        if (modeBtn) modeBtn.innerText = modeLabel(m);
        if (modeOptions) modeOptions.classList.remove("show");
        applyThemeMode(m);
        applyThemePreset(getStoredPreset());
      });
    });
  }

  document.addEventListener("click", (e) => {
    if (modeOptions && !modeOptions.contains(e.target) && e.target !== modeBtn) {
      modeOptions.classList.remove("show");
    }
  });

  document.querySelectorAll(".theme-preset-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      const p = btn.dataset.themePreset;
      if (!p || !THEME_PRESETS[p]) return;
      localStorage.setItem(THEME_PRESET_KEY, p);
      applyThemePreset(p);
    });
  });

  applyThemePreset(getStoredPreset());
  applySnackbarColors();
  bindSnackbarColorInputs();
  bindSnackbarColorTool();

  window.matchMedia("(prefers-color-scheme: light)").addEventListener("change", () => {
    if (getStoredMode() === "auto") {
      applyThemeMode("auto");
      applyThemePreset(getStoredPreset());
    }
  });

  document.addEventListener("languageChanged", () => {
    if (modeBtn) modeBtn.innerText = modeLabel(getStoredMode());
  });
});
