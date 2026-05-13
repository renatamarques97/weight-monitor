import { Controller } from "@hotwired/stimulus"

const THEME_STORAGE_KEY = "fit_tracker_theme"
const AVAILABLE_THEMES = ["light", "dark"]

export default class extends Controller {
  static targets = ["trigger", "dropdown", "themeButton", "chevron"]

  connect() {
    // Close menu when clicking outside
    document.addEventListener("click", this.handleOutsideClick.bind(this))
    // Update theme button on connect
    this.updateThemeButton()
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this))
  }

  toggleMenu(event) {
    event.stopPropagation()
    const isHidden = this.dropdownTarget.classList.contains("hidden")

    if (isHidden) {
      this.openMenu()
    } else {
      this.closeMenu()
    }
  }

  openMenu() {
    this.dropdownTarget.classList.remove("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    // Rotate chevron up
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.add("rotate-180")
    }
  }

  closeMenu() {
    this.dropdownTarget.classList.add("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "false")
    // Rotate chevron back down
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.remove("rotate-180")
    }
  }

  handleOutsideClick(event) {
    // Check if click is outside the container
    if (!this.element.contains(event.target)) {
      this.closeMenu()
    }
  }

  toggleTheme(event) {
    event.preventDefault()
    event.stopPropagation()

    const currentTheme = this.getCurrentTheme()
    const nextTheme = currentTheme === "dark" ? "light" : "dark"
    this.applyTheme(nextTheme)
    this.updateThemeButton()
  }

  getCurrentTheme() {
    const saved = localStorage.getItem(THEME_STORAGE_KEY)
    return AVAILABLE_THEMES.includes(saved) ? saved : "light"
  }

  applyTheme(theme) {
    const resolvedTheme = AVAILABLE_THEMES.includes(theme) ? theme : "light"
    document.documentElement.dataset.theme = resolvedTheme
    localStorage.setItem(THEME_STORAGE_KEY, resolvedTheme)
    
    // Trigger a repaint to ensure smooth transitions
    void document.documentElement.offsetHeight
  }

  updateThemeButton() {
    const currentTheme = this.getCurrentTheme()
    const isPressed = currentTheme === "dark"
    this.themeButtonTarget.setAttribute("aria-pressed", isPressed ? "true" : "false")
  }
}
