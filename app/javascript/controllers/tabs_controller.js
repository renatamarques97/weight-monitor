import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel", "periodLink"]
  static values = { activeTab: String }

  connect() {
    // Determine which tab to show based on value from controller or default to 0
    let index = this.tabTargets.findIndex(tab => tab.dataset.tabName === this.activeTabValue)
    if (index === -1) index = 0
    
    this.showTab(index, false)
  }

  switch(event) {
    event.preventDefault()
    const tab = event.currentTarget
    const index = this.tabTargets.indexOf(tab)
    const tabName = tab.dataset.tabName

    if (index >= 0) {
      this.showTab(index, true)
      this.updateUrl(tabName)
    }
  }

  showTab(index, updatePeriodLinks) {
    const activeTabName = this.tabTargets[index].dataset.tabName

    // 1. Update Panels
    this.panelTargets.forEach((panel, i) => {
      const active = i === index
      panel.hidden = !active
      panel.classList.toggle("hidden", !active)
      panel.style.display = active ? "grid" : "none"
    })

    // 2. Update Tabs
    this.tabTargets.forEach((tab, i) => {
      const active = i === index
      tab.dataset.active = active ? "true" : "false"
      tab.setAttribute("aria-selected", active ? "true" : "false")
    })

    // 3. Update Period Links (30, 60, 90 days)
    if (updatePeriodLinks) {
      this.periodLinkTargets.forEach(link => {
        const url = new URL(link.href)
        url.searchParams.set("active_tab", activeTabName)
        link.href = url.toString()
      })
    }
  }

  updateUrl(tabName) {
    const url = new URL(window.location)
    url.searchParams.set("active_tab", tabName)
    window.history.pushState({}, "", url)
  }
}
