// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const THEME_STORAGE_KEY = "fit_tracker_theme"
const DEFAULT_THEME = "light"
const AVAILABLE_THEMES = ["light", "dark"]

const resolveTheme = (theme) => (AVAILABLE_THEMES.includes(theme) ? theme : DEFAULT_THEME)

const applyTheme = (theme) => {
  const resolvedTheme = resolveTheme(theme)
  document.documentElement.dataset.theme = resolvedTheme
  document.documentElement.classList.toggle("dark", resolvedTheme === "dark")
  localStorage.setItem(THEME_STORAGE_KEY, resolvedTheme)

  void document.documentElement.offsetHeight

  applyChartTheme(resolvedTheme)
}

const applyChartTheme = (theme) => {
  if (typeof Chart === "undefined") return

  const isDark = theme === "dark"
  const textColor   = isDark ? "#9ca3af" : "#64748b"
  const gridColor   = isDark ? "rgba(148,163,184,0.08)" : "rgba(0,0,0,0.06)"
  const borderColor = isDark ? "rgba(148,163,184,0.15)" : "rgba(0,0,0,0.08)"

  Chart.defaults.color = textColor

  const scales = Chart.defaults.scales
  if (scales) {
    const applyScale = (scaleType) => {
      if (scales[scaleType]) {
        scales[scaleType].grid  = { ...(scales[scaleType].grid  || {}), color: gridColor, borderColor }
        scales[scaleType].ticks = { ...(scales[scaleType].ticks || {}), color: textColor }
      }
    }
    applyScale("linear")
    applyScale("category")
    applyScale("time")
  }
}

const syncThemeToggle = () => {
  const toggle = document.getElementById("theme-toggle")
  if (!toggle) {
    return
  }

  const currentTheme = resolveTheme(
    document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
  )
  const isDark = currentTheme === "dark"
  const stateText = isDark ? "Dark" : "Light"

  toggle.setAttribute("aria-pressed", String(isDark))
  toggle.setAttribute("aria-checked", String(isDark))
  toggle.setAttribute("title", `Theme ${stateText.toLowerCase()}`)
  toggle.dataset.themeState = currentTheme
}

const registerThemeToggle = () => {
  const toggle = document.getElementById("theme-toggle")
  if (!toggle) {
    return
  }
  
  if (toggle.dataset.listenerAttached === "true") {
    return
  }

  toggle.dataset.listenerAttached = "true"
  toggle.addEventListener("click", () => {
    const currentTheme = resolveTheme(
      document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
    )
    const nextTheme = currentTheme === "dark" ? "light" : "dark"
    applyTheme(nextTheme)
    syncThemeToggle()
  })
}

const bootTheme = () => {
  const initialTheme = resolveTheme(
    document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
  )

  applyTheme(initialTheme)
  syncThemeToggle()
  registerThemeToggle()
}

document.addEventListener("turbo:load", bootTheme)
document.addEventListener("turbo:frame-load", bootTheme)

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootTheme)
} else {
  bootTheme()
}
