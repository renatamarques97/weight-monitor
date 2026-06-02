import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "foodId"]
  timeout = null

  search(event) {
    clearTimeout(this.timeout)
    const query = event.target.value
    if (query.length < 3) {
      this.removeSuggestions()
      return
    }

    this.timeout = setTimeout(() => {
      fetch(`/fatsecret_foods?q=${encodeURIComponent(query)}`)
        .then(r => {
          if (!r.ok) {
            return r.json().then(payload => {
              throw new Error(payload.error || 'Erro na busca')
            })
          }
          return r.json()
        })
        .then(foods => {
          if (!Array.isArray(foods) || foods.length === 0) {
            this.showError('Nenhum alimento encontrado para esta busca.')
            return
          }
          this.showSuggestions(foods)
        })
        .catch(error => this.showError(error.message || 'Nao foi possivel buscar alimentos. Tente novamente em instantes.'))
    }, 300)
  }

  showError(message) {
    this.removeSuggestions()
    const ul = document.createElement('ul')
    ul.className = 'autocomplete-suggestions'
    const li = document.createElement('li')
    li.textContent = message
    li.className = 'autocomplete-error-message'
    ul.appendChild(li)
    this.inputTarget.parentNode.appendChild(ul)
  }

  showSuggestions(foods) {
    this.removeSuggestions()
    if (!foods.length) return
    const ul = document.createElement('ul')
    ul.className = 'autocomplete-suggestions'
    foods.forEach(food => {
      const li = document.createElement('li')
      li.textContent = food.food_name
      li.tabIndex = 0
      li.onclick = () => this.selectFood(food)
      ul.appendChild(li)
    })
    this.inputTarget.parentNode.appendChild(ul)
  }

  selectFood(food) {
    this.inputTarget.value = food.food_name
    this.foodIdTarget.value = food.food_id
    this.removeSuggestions()
    // Buscar detalhes do alimento
    fetch(`/fatsecret_foods/${food.food_id}`)
      .then(r => r.json())
      .then(data => this.fillMacros(data))
  }

  fillMacros(data) {
    if (!data.food || !data.food.servings || !data.food.servings.serving) return
    const serving = Array.isArray(data.food.servings.serving) ? data.food.servings.serving[0] : data.food.servings.serving
    this.element.querySelector('[name*="[calories]"]').value = serving.calories
    this.element.querySelector('[name*="[protein]"]').value = serving.protein
    this.element.querySelector('[name*="[carbs]"]').value = serving.carbohydrate
    this.element.querySelector('[name*="[fat]"]').value = serving.fat
    this.element.querySelector('[name*="[metric_serving_unit]"]').value = serving.metric_serving_unit
  }

  removeSuggestions() {
    const ul = this.inputTarget.parentNode.querySelector('.autocomplete-suggestions')
    if (ul) ul.remove()
  }
}
