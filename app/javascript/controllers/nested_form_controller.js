import { Controller } from "@hotwired/stimulus"

// Adds and removes nested form rows without depending on jQuery/cocoon.
export default class extends Controller {
  static targets = ["template", "list"]

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now().toString())
    this.listTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()

    const wrapper = event.currentTarget.closest("[data-nested-form-wrapper]")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("input[name*='[_destroy]']")
    const idField = wrapper.querySelector("input[name*='[id]']")
    const persistedRecord = idField && idField.value

    if (destroyField && persistedRecord) {
      destroyField.value = "1"

      wrapper.querySelectorAll("input, select, textarea, button").forEach((element) => {
        if (element === destroyField || element === idField) return
        element.disabled = true
      })

      wrapper.hidden = true
      return
    }

    wrapper.remove()
  }
}
