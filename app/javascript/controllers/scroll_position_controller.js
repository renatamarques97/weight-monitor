import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }

  connect() {
    const saved = sessionStorage.getItem(this.keyValue)
    if (saved !== null) {
      this.element.scrollLeft = Number(saved)
    }
  }

  save() {
    sessionStorage.setItem(this.keyValue, String(this.element.scrollLeft))
  }
}
