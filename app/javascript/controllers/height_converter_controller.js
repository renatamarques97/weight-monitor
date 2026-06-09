import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "select", "label"]
  static values = {
    placeholderFt: String,
    placeholderCm: String,
    placeholderM: String
  }

  connect() {
    this.currentUnit = this.selectTarget.value
  }

  async convert() {
    const newUnit = this.selectTarget.value
    const oldUnit = this.currentUnit

    if (newUnit === oldUnit) return

    const rawValue = parseFloat(this.inputTarget.value)
    if (!isNaN(rawValue)) {
      try {
        const response = await fetch(`/unit_conversions/convert?value=${rawValue}&from_unit=${oldUnit}&to_unit=${newUnit}&type=height`)
        if (response.ok) {
          const data = await response.json()
          if (data && data.value !== null) {
            this.inputTarget.value = data.value.toString()
          }
        }
      } catch (error) {
        console.error("Failed to convert height", error)
      }
    }

    if (this.hasInputTarget) {
      let placeholder = this.placeholderMValue
      if (newUnit === "ft") {
        placeholder = this.placeholderFtValue
      } else if (newUnit === "cm") {
        placeholder = this.placeholderCmValue
      }

      this.inputTarget.placeholder = placeholder
    }

    this.currentUnit = newUnit
  }
}
