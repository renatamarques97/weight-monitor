import { Controller } from "@hotwired/stimulus"

// Keeps labels that mention a unit in sync with the unit select they depend on.
// Selects and labels are paired by data-unit-label-key; each label carries its
// text in data-unit-label-template, with __unit__ where the unit goes.
export default class extends Controller {
  static targets = ["select", "label"]

  connect() {
    this.selectTargets.forEach((select) => this.refresh(select))
  }

  update(event) {
    this.refresh(event.target)
  }

  refresh(select) {
    const key = select.dataset.unitLabelKey

    this.labelTargets
      .filter((label) => label.dataset.unitLabelKey === key)
      .forEach((label) => {
        label.textContent = label.dataset.unitLabelTemplate.replace("__unit__", select.value)
      })
  }
}
