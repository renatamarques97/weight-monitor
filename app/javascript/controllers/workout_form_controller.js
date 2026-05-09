import { Controller } from "@hotwired/stimulus"

// Manages dynamic visibility of sport-specific form fields
// based on the selected workout_type.
export default class extends Controller {
  static targets = [
    "typeSelect",
    "distanceField",
    "runningFields",
    "walkingFields",
    "cyclingFields",
    "swimmingFields",
    "weightliftingFields",
    "yogaFields",
    "soccerFields",
    "basketballFields",
    "tennisFields",
    "martialArtsFields"
  ]

  // Distance-based sports that show the distance field
  static DISTANCE_SPORTS = ["running", "walking", "cycling", "swimming"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const type = this.typeSelectTarget.value

    // Distance field visibility
    const showDistance = this.constructor.DISTANCE_SPORTS.includes(type)
    this.toggle(this.distanceFieldTarget, showDistance)

    // Sport-specific detail fields
    this.toggle(this.runningFieldsTarget, type === "running")
    this.toggle(this.walkingFieldsTarget, type === "walking")
    this.toggle(this.cyclingFieldsTarget, type === "cycling")
    this.toggle(this.swimmingFieldsTarget, type === "swimming")
    this.toggle(this.weightliftingFieldsTarget, type === "weightlifting")
    this.toggle(this.yogaFieldsTarget, type === "yoga")
    this.toggle(this.soccerFieldsTarget, type === "soccer")
    this.toggle(this.basketballFieldsTarget, type === "basketball")
    this.toggle(this.tennisFieldsTarget, type === "tennis")
    this.toggle(this.martialArtsFieldsTarget, type === "martial_arts")
  }

  toggle(element, visible) {
    element.style.display = visible ? "" : "none"
  }
}
