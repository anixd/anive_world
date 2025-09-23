import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
    static targets = ["source", "target"]
    static values = { url: String }

    connect() {
        if (this.sourceTarget.value) {
            this.fetch()
        }
    }

    fetch() {
        const selectedId = this.sourceTarget.value
        if (!selectedId) {
            this.targetTarget.innerHTML = `<p class="text-gray-500 text-sm italic">Select a language to see options...</p>`
            return
        }

        const url = new URL(this.urlValue, window.location.origin)
        url.searchParams.set("language_id", selectedId)

        // Просто отправляем запрос, который вернет Turbo Stream.
        // Turbo сам его поймает и выполнит. Никакой ручной обработки ответа не нужно.
        get(url, { responseKind: "turbo-stream" })
    }
}