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
  const values = {
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

document.addEventListener("click", (event) => {
  const clickedSuggestion = event.target.closest(".autocomplete-suggestions")
  if (clickedSuggestion) return

  document.querySelectorAll(".fatsecret-autocomplete").forEach((input) => {
    fsRemoveSuggestions(input)
  })
})
