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
    this.#updateLastMessageId()
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

    let streamedText = ""
    const eventSource = new EventSource(`/chat_responses?${params}`)

    eventSource.addEventListener("message", (e) => {
      const { message } = JSON.parse(e.data)
      streamedText += message
      bubble.querySelector(".chat-markdown").innerHTML = this.#renderMarkdown(streamedText)
      this.#scrollToBottom()
    })

    eventSource.addEventListener("error", () => {
      eventSource.close()
      this.isLoadingValue = false
      this.#replaceLastBubbles()
    })
  }

  #renderMarkdown(text) {
    const escapeHtml = (value) => {
      const element = document.createElement("div")
      element.textContent = value
      return element.innerHTML
    }

    const inline = (value) => escapeHtml(value)
      .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
      .replace(/__(.+?)__/g, "<strong>$1</strong>")
      .replace(/\*(.+?)\*/g, "<em>$1</em>")
      .replace(/_(.+?)_/g, "<em>$1</em>")

    const html = []
    let listItems = []

    const flushList = () => {
      if (listItems.length) {
        html.push(`<ul>${listItems.join("")}</ul>`)
        listItems = []
      }
    }

    text.replace(/\r/g, "").split("\n").forEach((line) => {
      let match

      if ((match = line.match(/^###\s+(.+)$/))) {
        flushList()
        html.push(`<h3>${inline(match[1])}</h3>`)
      } else if ((match = line.match(/^##\s+(.+)$/))) {
        flushList()
        html.push(`<h2>${inline(match[1])}</h2>`)
      } else if ((match = line.match(/^#\s+(.+)$/))) {
        flushList()
        html.push(`<h1>${inline(match[1])}</h1>`)
      } else if ((match = line.match(/^[-*]\s+(.+)$/))) {
        listItems.push(`<li>${inline(match[1])}</li>`)
      } else if (!line.trim()) {
        flushList()
      } else {
        flushList()
        html.push(`<p>${inline(line)}</p>`)
      }
    })

    flushList()
    return html.join("")
  }

  async #replaceLastBubbles() {
    const response = await fetch(`/chats.json?after_id=${this.lastMessageId}`)
    const data = await response.json()
    if (!data.messages_html) return

    const dynamicBubbles = this.conversationTarget.querySelectorAll(".dynamic-bubble")
    dynamicBubbles.forEach(bubble => bubble.remove())

    this.conversationTarget.insertAdjacentHTML("beforeend", data.messages_html)
    this.#updateLastMessageId()
    this.#scrollToBottom()
  }

  #updateLastMessageId() {
    const staticMessages = this.conversationTarget.querySelectorAll("[chat-message-id]")

    this.lastMessageId = 0

    if (staticMessages.length > 0) {
      const lastMessage = staticMessages[staticMessages.length - 1]
      this.lastMessageId = parseInt(lastMessage.getAttribute("chat-message-id"), 10)
    }
  }

  #appendBubble(role, text) {
    const wrapper = document.createElement("div")
    wrapper.className = `message-bubble dynamic-bubble chat-bubble-wrapper ${role} animate-fade-in-up`

    const label = document.createElement("span")
    label.className = "chat-bubble-label"
    label.textContent = role === "user" ? this.userLabelValue : this.assistantLabelValue

    const bubble = document.createElement("div")
    bubble.className = `chat-bubble ${role}`

    const content = document.createElement("div")
    content.className = "chat-markdown"

    if (role === "assistant") {
      content.innerHTML = ""
    } else {
      content.classList.add("chat-user-message")
      content.textContent = text
    }

    bubble.appendChild(content)
    wrapper.append(label, bubble)
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
