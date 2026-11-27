import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "message"]

  connect() {
    this.buttonClickHandler = () => this.submitted()
    if (this.hasButtonTarget) {
      this.buttonTarget.addEventListener("click", this.buttonClickHandler)
    }
  }

  disconnect() {
    if (this.hasButtonTarget && this.buttonClickHandler) {
      this.buttonTarget.removeEventListener("click", this.buttonClickHandler)
    }
  }

  submitted() {
    if (!this.hasButtonTarget) return

    this.buttonTarget.disabled = true
    this.buttonTarget.innerHTML = '<i class="fa fa-spinner fa-spin mr-2"></i>Sincronizando...'
    if (this.hasMessageTarget) this.messageTarget.textContent = ""
  }
}
