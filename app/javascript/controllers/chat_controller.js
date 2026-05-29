import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt", "conversation", "objective"]
  static values = {
    isLoading: Boolean,
    userLabel: { type: String, default: "You" },
    assistantLabel: { type: String, default: "Diet suggester" }
  }

  connect() {
    this.isLoadingValue = false
    this.currentOldestPage = parseInt(this.conversationTarget.dataset.chatCurrentPage, 10) || 1
    if (this.hasPromptTarget) {
      this.resizePrompt()
      this.resizeHandler = () => this.resizePrompt()
      window.addEventListener("resize", this.resizeHandler)
    }
    requestAnimationFrame(() => {
      this.#scrollToBottom()
      this.#ensureScrollableHistory()
    })
  }

  disconnect() {
    this.eventSource?.close()
    if (this.resizeHandler) {
      window.removeEventListener("resize", this.resizeHandler)
    }
  }

  onScroll() {
    const { scrollTop } = this.conversationTarget
    if (scrollTop < 100 && !this.isLoadingValue && this.currentOldestPage > 1) {
      this.#loadOlderMessages()
    }
  }

  resizePrompt() {
    if (!this.hasPromptTarget) return
    this.promptTarget.style.height = "auto"
    const scrollHeight = this.promptTarget.scrollHeight
    const maxHeight = 150
    if (scrollHeight > maxHeight) {
      this.promptTarget.style.height = `${maxHeight}px`
      this.promptTarget.style.overflowY = "auto"
    } else {
      this.promptTarget.style.height = `${scrollHeight}px`
      this.promptTarget.style.overflowY = "hidden"
    }
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      const form = this.promptTarget.form
      if (form) {
        if (typeof form.requestSubmit === "function") {
          form.requestSubmit()
        } else {
          form.dispatchEvent(new Event("submit", { cancelable: true, bubbles: true }))
        }
      }
    }
  }

  async generateResponse(event) {
    event.preventDefault()
    const text = this.promptTarget.value.trim()
    if (!text) return

    this.promptTarget.value = ""
    this.resizePrompt()
    this.isLoadingValue = true

    this.#appendBubble("user", text)
    const bubble = this.#appendBubble("assistant", "")

    const params = new URLSearchParams({ prompt: text })
    if (this.hasObjectiveTarget) params.append("objective", this.objectiveTarget.value)

    const eventSource = new EventSource(`/chat_responses?${params}`)

    eventSource.addEventListener("message", (e) => {
      const { message } = JSON.parse(e.data)
      bubble.querySelector("pre").textContent += message
      this.#scrollToBottom()
    })

    eventSource.addEventListener("error", () => {
      eventSource.close()
      this.isLoadingValue = false
      this.#replaceLastBubbles()
    })
  }

  async #replaceLastBubbles() {
    const response = await fetch("/chats.json")
    const data = await response.json()
    if (!data.messages_html) return

    const bubbles = this.conversationTarget.querySelectorAll(".message-bubble")
    bubbles[bubbles.length - 1]?.remove()
    bubbles[bubbles.length - 2]?.remove()

    this.conversationTarget.insertAdjacentHTML("beforeend", data.messages_html)
    this.#scrollToBottom()
  }

  #appendBubble(role, text) {
    const wrapper = document.createElement("div")
    wrapper.classList.add("message-bubble")
    wrapper.innerHTML = `
      <strong class="chat-message-label">
        ${role === "assistant" ? this.assistantLabelValue : this.userLabelValue}:
      </strong>
      <pre class="chat-message-content">${text}</pre>
    `
    this.conversationTarget.appendChild(wrapper)
    this.#scrollToBottom()
    return wrapper
  }

  async #loadOlderMessages() {
    const pageToLoad = this.currentOldestPage - 1
    if (pageToLoad < 1) return

    this.isLoadingValue = true
    try {
      const response = await fetch(`/chats.json?page=${pageToLoad}`)
      const data = await response.json()
      if (!data.messages_html?.trim()) {
        this.currentOldestPage = 1
        return
      }

      const { scrollHeight, scrollTop } = this.conversationTarget
      this.conversationTarget.insertAdjacentHTML("afterbegin", data.messages_html)
      this.currentOldestPage = Math.max(data.pagination?.page ?? pageToLoad, 1)
      this.conversationTarget.scrollTop = scrollTop + (this.conversationTarget.scrollHeight - scrollHeight)
    } catch (error) {
      console.error("Error loading older messages:", error)
    } finally {
      this.isLoadingValue = false
    }
  }

  async #ensureScrollableHistory() {
    while (!this.#isScrollable() && this.currentOldestPage > 1 && !this.isLoadingValue) {
      await this.#loadOlderMessages()
    }
    this.#scrollToBottom()
  }

  #isScrollable() {
    const el = this.conversationTarget
    return el.scrollHeight > el.clientHeight
  }

  #scrollToBottom() {
    this.conversationTarget.scrollTop = this.conversationTarget.scrollHeight
  }
}
