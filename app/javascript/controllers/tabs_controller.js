import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.showTab(0)
  }

  switch(event) {
    event.preventDefault()
    // Find closest tab target in case a child icon is clicked
    const tabClicked = event.currentTarget
    const index = this.tabTargets.indexOf(tabClicked)
    if (index >= 0) {
      this.showTab(index)
    }
  }

  showTab(index) {
    const activeClasses = ["border-emerald-600", "text-emerald-600"]
    const inactiveClasses = ["border-transparent", "text-slate-500", "hover:text-slate-700", "hover:border-slate-300"]

    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.hidden = false
        panel.classList.remove("hidden")
        panel.style.display = "block"
      } else {
        panel.hidden = true
        panel.classList.add("hidden")
        panel.style.display = "none"
      }
    })

    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add(...activeClasses)
        tab.classList.remove(...inactiveClasses)
        tab.setAttribute("aria-selected", "true")
      } else {
        tab.classList.add(...inactiveClasses)
        tab.classList.remove(...activeClasses)
        tab.setAttribute("aria-selected", "false")
      }
    })
  }
}
