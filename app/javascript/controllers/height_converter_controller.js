import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "select", "label"]

  connect() {
    this.currentUnit = this.selectTarget.value
    this.labelText = this.labelTarget.textContent
    this.updateLabel(this.currentUnit)
  }

  async convert() {
    const newUnit = this.selectTarget.value
    const oldUnit = this.currentUnit

    if (newUnit === oldUnit) return

    const rawValue = this.inputTarget.value.trim()
    if (rawValue) {
      const value = Number(rawValue)
      if (!Number.isFinite(value)) {
        this.selectTarget.value = oldUnit
        return
      }

      this.selectTarget.disabled = true
      try {
        const params = new URLSearchParams({
          value: value.toString(),
          from_unit: oldUnit,
          to_unit: newUnit,
          type: "height"
        })
        const response = await fetch(`/unit_conversions/convert?${params}`)
        if (!response.ok) throw new Error(`Conversion failed with status ${response.status}`)

        const data = await response.json()
        if (!Number.isFinite(data.value)) throw new Error("Conversion returned an invalid value")

        this.inputTarget.value = data.value.toString()
      } catch (error) {
        console.error("Failed to convert height", error)
        this.selectTarget.value = oldUnit
        return
      } finally {
        this.selectTarget.disabled = false
      }
    }

    this.inputTarget.placeholder = newUnit
    this.updateLabel(newUnit)
    this.currentUnit = newUnit
  }

  updateLabel(unit) {
    this.labelTarget.textContent = `${this.labelText} (${unit})`
  }
}
