import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
    static targets = ["prompt", "conversation", "objective"]

    disconnect() {
        if (this.eventSource) {
            this.eventSource.close()
        }
    }

    generateResponse(event) {
        event.preventDefault()

        if (!this.promptTarget.value.trim()) {
            return
        }

        this.#createLabel('You')
        this.#createMessage(this.promptTarget.value)
        this.#createLabel('Diet suggester')
        this.currentPre = this.#createMessage()

        this.#setupEventSource()

        this.promptTarget.value = ""
    }

    #createLabel(text) {
        const label = document.createElement('strong');
        label.className = 'mt-3 inline-block text-[11px] font-semibold uppercase tracking-wide text-slate-500'
        label.textContent = `${text}:`;
        this.conversationTarget.appendChild(label);
    }

    #createMessage(text = '') {
        const preElement = document.createElement('pre');
        preElement.className = 'mt-1 whitespace-pre-wrap rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800'
        preElement.textContent = text;
        this.conversationTarget.appendChild(preElement);
        return preElement
    }

    #setupEventSource() {
        const prompt = encodeURIComponent(this.promptTarget.value)
        const objective = this.hasObjectiveTarget ? encodeURIComponent(this.objectiveTarget.value) : ""
        this.eventSource = new EventSource(`/chat_responses?prompt=${prompt}&objective=${objective}`)
        this.eventSource.addEventListener("message", this.#handleMessage.bind(this))
        this.eventSource.addEventListener("error", this.#handleError.bind(this))
    }

    #handleMessage(event) {
        const parsedData = JSON.parse(event.data);
        this.currentPre.textContent += parsedData.message;

        this.conversationTarget.scrollTop = this.conversationTarget.scrollHeight;
    }

    #handleError(event) {
        if (event.eventPhase === EventSource.CLOSED) {
            this.eventSource.close()
        } else {
            this.currentPre.textContent += "\n\nHouve um problema ao gerar a resposta. Tente novamente."
        }
    }
}
