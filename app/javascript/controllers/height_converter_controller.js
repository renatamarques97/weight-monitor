import { Controller } from "@hotwired/stimulus"

// Converts the height input when the height unit select changes. The server parses
// and formats the value, so feet can be typed and shown as feet and inches (5'9").
// The base label comes from a value, not from the DOM: reading textContent on
// connect would append the unit again when Turbo restores a cached page.
export default class extends Controller {
  static targets = ["input", "select", "label"]
  static values = { label: String, placeholders: Object }

  connect() {
    this.currentUnit = this.selectTarget.value
  }

  async convert() {
    const newUnit = this.selectTarget.value
    const oldUnit = this.currentUnit

    if (newUnit === oldUnit) return

    const rawValue = this.inputTarget.value.trim()
    if (rawValue) {
      this.selectTarget.disabled = true
      try {
        const params = new URLSearchParams({ value: rawValue, from_unit: oldUnit, to_unit: newUnit, type: "height" })
        const response = await fetch(`/unit_conversions/convert?${params}`, {
          headers: { Accept: "application/json" }
        })
        if (!response.ok) throw new Error(`Conversion failed with status ${response.status}`)

        const data = await response.json()
        if (!Number.isFinite(data.value)) throw new Error("Conversion returned an invalid value")

        this.inputTarget.value = data.display
      } catch (error) {
        console.error("Failed to convert height", error)
        this.selectTarget.value = oldUnit
        return
      } finally {
        this.selectTarget.disabled = false
      }
    }

    this.inputTarget.placeholder = this.placeholdersValue[newUnit] || newUnit
    this.labelTarget.textContent = `${this.labelValue} (${newUnit})`
    this.currentUnit = newUnit
  }
}
