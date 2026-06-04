// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const THEME_STORAGE_KEY = "fit_tracker_theme"
const DEFAULT_THEME = "light"
const AVAILABLE_THEMES = ["light", "dark"]

const resolveTheme = (theme) => (AVAILABLE_THEMES.includes(theme) ? theme : DEFAULT_THEME)

const applyTheme = (theme) => {
  const resolvedTheme = resolveTheme(theme)
  document.documentElement.dataset.theme = resolvedTheme
  document.documentElement.classList.toggle("dark", resolvedTheme === "dark")
  localStorage.setItem(THEME_STORAGE_KEY, resolvedTheme)

  void document.documentElement.offsetHeight

  applyChartTheme(resolvedTheme)
}

const applyChartTheme = (theme) => {
  if (typeof Chart === "undefined") return

  const isDark = theme === "dark"
  const textColor   = isDark ? "#9ca3af" : "#64748b"
  const gridColor   = isDark ? "rgba(148,163,184,0.08)" : "rgba(0,0,0,0.06)"
  const borderColor = isDark ? "rgba(148,163,184,0.15)" : "rgba(0,0,0,0.08)"

  Chart.defaults.color = textColor

  const scales = Chart.defaults.scales
  if (scales) {
    const applyScale = (scaleType) => {
      if (scales[scaleType]) {
        scales[scaleType].grid  = { ...(scales[scaleType].grid  || {}), color: gridColor, borderColor }
        scales[scaleType].ticks = { ...(scales[scaleType].ticks || {}), color: textColor }
      }
    }
    applyScale("linear")
    applyScale("category")
    applyScale("time")
  }
}

const syncThemeToggle = () => {
  const toggle = document.getElementById("theme-toggle")
  if (!toggle) {
    return
  }

  const currentTheme = resolveTheme(
    document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
  )
  const isDark = currentTheme === "dark"
  const stateText = isDark ? "Dark" : "Light"

  toggle.setAttribute("aria-pressed", String(isDark))
  toggle.setAttribute("aria-checked", String(isDark))
  toggle.setAttribute("title", `Theme ${stateText.toLowerCase()}`)
  toggle.dataset.themeState = currentTheme
}

const registerThemeToggle = () => {
  const toggle = document.getElementById("theme-toggle")
  if (!toggle) {
    return
  }
  
  if (toggle.dataset.listenerAttached === "true") {
    return
  }

  toggle.dataset.listenerAttached = "true"
  toggle.addEventListener("click", () => {
    const currentTheme = resolveTheme(
      document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
    )
    const nextTheme = currentTheme === "dark" ? "light" : "dark"
    applyTheme(nextTheme)
    syncThemeToggle()
  })
}

const bootTheme = () => {
  const initialTheme = resolveTheme(
    document.documentElement.dataset.theme || localStorage.getItem(THEME_STORAGE_KEY)
  )

  applyTheme(initialTheme)
  syncThemeToggle()
  registerThemeToggle()
}

document.addEventListener("turbo:load", bootTheme)
document.addEventListener("turbo:frame-load", bootTheme)

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootTheme)
} else {
  bootTheme()
}

const fsTimers = new WeakMap()

const fsFieldName = (input, field) => {
  if (!input.name) return null
  return input.name.replace("[food_name]", `[${field}]`)
}

const fsFindField = (input, field) => {
  const name = fsFieldName(input, field)
  if (!name) return null
  return document.querySelector(`[name="${name}"]`)
}

const fsRemoveSuggestions = (input) => {
  const container = input.parentElement
  if (!container) return
  const existing = container.querySelector(".autocomplete-suggestions")
  if (existing) existing.remove()
}

const fsShowMessage = (input, message, isError = false) => {
  fsRemoveSuggestions(input)
  const container = input.parentElement
  if (!container) return

  const ul = document.createElement("ul")
  ul.className = "autocomplete-suggestions"

  const li = document.createElement("li")
  li.textContent = message
  if (isError) li.className = "autocomplete-error-message"

  ul.appendChild(li)
  container.appendChild(ul)
}

const fsFillMacros = (input, data) => {
  const serving = data?.food?.servings?.serving
  if (!serving) return

  const firstServing = Array.isArray(serving) ? serving[0] : serving
  const servingAmount = parseFloat(firstServing.metric_serving_amount || "0")
  const values = {
    metric_serving_amount: firstServing.metric_serving_amount,
    calories: firstServing.calories,
    protein: firstServing.protein,
    carbs: firstServing.carbohydrate,
    fat: firstServing.fat,
    metric_serving_unit: firstServing.metric_serving_unit
  }

  Object.entries(values).forEach(([field, value]) => {
    const el = fsFindField(input, field)
    if (el) el.value = value || ""
  })

  if (servingAmount > 0) {
    input.dataset.fsPerUnitCalories = (parseFloat(firstServing.calories || "0") / servingAmount).toString()
    input.dataset.fsPerUnitProtein = (parseFloat(firstServing.protein || "0") / servingAmount).toString()
    input.dataset.fsPerUnitCarbs = (parseFloat(firstServing.carbohydrate || "0") / servingAmount).toString()
    input.dataset.fsPerUnitFat = (parseFloat(firstServing.fat || "0") / servingAmount).toString()
  }
}

const fsRound = (value) => {
  if (Number.isNaN(value)) return ""
  return Math.round(value * 100) / 100
}

const fsEnsurePerUnitFromCurrent = (foodInput) => {
  const amountField = fsFindField(foodInput, "metric_serving_amount")
  const amount = parseFloat(amountField?.value || "0")
  if (!(amount > 0)) return false

  const calories = parseFloat(fsFindField(foodInput, "calories")?.value || "0")
  const protein = parseFloat(fsFindField(foodInput, "protein")?.value || "0")
  const carbs = parseFloat(fsFindField(foodInput, "carbs")?.value || "0")
  const fat = parseFloat(fsFindField(foodInput, "fat")?.value || "0")

  foodInput.dataset.fsPerUnitCalories = (calories / amount).toString()
  foodInput.dataset.fsPerUnitProtein = (protein / amount).toString()
  foodInput.dataset.fsPerUnitCarbs = (carbs / amount).toString()
  foodInput.dataset.fsPerUnitFat = (fat / amount).toString()

  return true
}

const fsRecalculateMacros = (amountInput) => {
  const amountName = amountInput.name
  if (!amountName) return

  const foodName = amountName.replace("[metric_serving_amount]", "[food_name]")
  const foodInput = document.querySelector(`[name="${foodName}"]`)
  if (!foodInput) return

  const amount = parseFloat(amountInput.value || "0")
  if (!(amount > 0)) return

  const hasDataset = foodInput.dataset.fsPerUnitCalories && foodInput.dataset.fsPerUnitProtein
  if (!hasDataset && !fsEnsurePerUnitFromCurrent(foodInput)) return

  const perCalories = parseFloat(foodInput.dataset.fsPerUnitCalories || "0")
  const perProtein = parseFloat(foodInput.dataset.fsPerUnitProtein || "0")
  const perCarbs = parseFloat(foodInput.dataset.fsPerUnitCarbs || "0")
  const perFat = parseFloat(foodInput.dataset.fsPerUnitFat || "0")

  const caloriesField = fsFindField(foodInput, "calories")
  const proteinField = fsFindField(foodInput, "protein")
  const carbsField = fsFindField(foodInput, "carbs")
  const fatField = fsFindField(foodInput, "fat")

  if (caloriesField) caloriesField.value = fsRound(perCalories * amount)
  if (proteinField) proteinField.value = fsRound(perProtein * amount)
  if (carbsField) carbsField.value = fsRound(perCarbs * amount)
  if (fatField) fatField.value = fsRound(perFat * amount)
}

const fsSelectFood = (input, food) => {
  input.value = food.food_name || ""

  const idField = fsFindField(input, "fatsecret_food_id")
  if (idField) idField.value = food.food_id || ""

  fsRemoveSuggestions(input)

  if (!food.food_id) return
  fetch(`/fatsecret_foods/${food.food_id}`)
    .then((r) => r.json())
    .then((payload) => fsFillMacros(input, payload))
    .catch(() => fsShowMessage(input, "Falha ao carregar macros do alimento.", true))
}

const fsShowSuggestions = (input, foods) => {
  fsRemoveSuggestions(input)
  const container = input.parentElement
  if (!container) return

  const ul = document.createElement("ul")
  ul.className = "autocomplete-suggestions"

  foods.forEach((food) => {
    const li = document.createElement("li")
    li.textContent = food.food_name || "(sem nome)"
    li.tabIndex = 0
    li.addEventListener("click", () => fsSelectFood(input, food))
    li.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        event.preventDefault()
        fsSelectFood(input, food)
      }
    })
    ul.appendChild(li)
  })

  container.appendChild(ul)
}

const fsSearchFoods = (input) => {
  const query = input.value.trim()
  if (query.length < 3) {
    fsRemoveSuggestions(input)
    return
  }

  fetch(`/fatsecret_foods?q=${encodeURIComponent(query)}`)
    .then(async (r) => {
      if (!r.ok) {
        const payload = await r.json().catch(() => ({}))
        throw new Error(payload.error || "Nao foi possivel buscar alimentos agora.")
      }
      return r.json()
    })
    .then((foods) => {
      if (!Array.isArray(foods) || foods.length === 0) {
        fsShowMessage(input, "Nenhum alimento encontrado.")
        return
      }
      fsShowSuggestions(input, foods)
    })
    .catch((error) => fsShowMessage(input, error.message, true))
}

document.addEventListener("input", (event) => {
  const input = event.target.closest(".fatsecret-autocomplete")
  if (!input) return

  const previous = fsTimers.get(input)
  if (previous) clearTimeout(previous)

  const timer = setTimeout(() => fsSearchFoods(input), 300)
  fsTimers.set(input, timer)
})

document.addEventListener("input", (event) => {
  const amountInput = event.target.closest(".fatsecret-serving-amount")
  if (!amountInput) return

  fsRecalculateMacros(amountInput)
})

document.addEventListener("click", (event) => {
  const clickedSuggestion = event.target.closest(".autocomplete-suggestions")
  if (clickedSuggestion) return

  document.querySelectorAll(".fatsecret-autocomplete").forEach((input) => {
    fsRemoveSuggestions(input)
  })
})
