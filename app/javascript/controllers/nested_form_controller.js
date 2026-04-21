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

    const wrapper = event.target.closest("[data-nested-form-wrapper]")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("input[name*='[_destroy]']")
    if (destroyField) {
      destroyField.value = "1"
      wrapper.classList.add("d-none")
      return
    }

    wrapper.remove()
  }
}
