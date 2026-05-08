import { Controller } from "@hotwired/stimulus"

const THEME_STORAGE_KEY = "fit_tracker_theme"
const AVAILABLE_THEMES = ["light", "dark"]
const DEFAULT_THEME = "light"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    const currentTheme = this.resolveTheme(
      document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
    )

    this.applyTheme(currentTheme)

    if (this.hasSelectTarget) {
      this.selectTarget.value = currentTheme
    }
  }

  change(event) {
    const selectedTheme = this.resolveTheme(event.target.value)
    this.applyTheme(selectedTheme)
  }

  applyTheme(theme) {
    document.documentElement.dataset.theme = theme
    localStorage.setItem(THEME_STORAGE_KEY, theme)
  }

  resolveTheme(theme) {
    return AVAILABLE_THEMES.includes(theme) ? theme : DEFAULT_THEME
  }
}
