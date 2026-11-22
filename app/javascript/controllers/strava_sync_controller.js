import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "message"]
  static values = { statusUrl: String }

  connect() {
    this.syncRequested = sessionStorage.getItem("strava_sync_requested") === "true"
    this.previousStatus = null
    this.reloadScheduled = false

    this.buttonClickHandler = () => this.submitted()
    if (this.hasButtonTarget) {
      this.buttonTarget.addEventListener("click", this.buttonClickHandler)
    }

    this.poll()
  }

  disconnect() {
    if (this.hasButtonTarget && this.buttonClickHandler) {
      this.buttonTarget.removeEventListener("click", this.buttonClickHandler)
    }
    this.stopPolling()
  }

  submitted() {
    sessionStorage.setItem("strava_sync_requested", "true")
    this.syncRequested = true
    this.previousStatus = "syncing"
    this.render("syncing", 0, null)

    if (!this.timer) {
      this.refresh()
      this.timer = window.setInterval(() => this.refresh(), 2000)
    }
  }

  async poll() {
    this.stopPolling()
    await this.refresh()
  }

  stopPolling() {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = null
    }
  }

  async refresh() {
    try {
      const response = await fetch(this.statusUrlValue, {
        headers: { Accept: "application/json" },
        cache: "no-store"
      })
      if (!response.ok) return

      const status = await response.json()
      this.render(status.status, status.imported_count, status.error)

      if (status.status === "syncing") {
        this.previousStatus = "syncing"
        if (!this.timer) this.timer = window.setInterval(() => this.refresh(), 2000)
        return
      }

      this.stopPolling()

      const syncFinished = status.status === "synced" || status.status === "failed"
      if (this.syncRequested && syncFinished && !this.reloadScheduled) {
        this.reloadScheduled = true
        sessionStorage.removeItem("strava_sync_requested")
        window.setTimeout(() => window.location.reload(), 300)
      }

      this.previousStatus = status.status
    } catch (_error) {
      // Mantém o polling ativo durante o estado syncing.
    }
  }

  render(status, importedCount, error) {
    if (!this.hasButtonTarget) return

    if (status === "syncing") {
      this.buttonTarget.disabled = true
      this.buttonTarget.innerHTML = '<i class="fa fa-spinner fa-spin mr-2"></i>Sincronizando...'
      if (this.hasMessageTarget) this.messageTarget.textContent = ""
      return
    }

    this.buttonTarget.disabled = false

    if (status === "synced") {
      this.buttonTarget.innerHTML = '<i class="fa fa-check mr-2"></i>Sincronizado'
      if (this.hasMessageTarget) {
        this.messageTarget.textContent = `${importedCount} atividade(s) importada(s)`
      }
      return
    }

    if (status === "failed") {
      this.buttonTarget.innerHTML = '<i class="fa fa-rotate mr-2"></i>Tentar novamente'
      if (this.hasMessageTarget) this.messageTarget.textContent = error || "Falha na sincronização"
      return
    }

    this.buttonTarget.innerHTML = '<i class="fa fa-arrows-rotate mr-2"></i>Sincronizar Strava'
  }
}
