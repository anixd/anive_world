import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["source", "target"]
    static values = { url: String }

    update() {
        const selectedLanguageId = this.sourceTarget.value

        if (!selectedLanguageId) {
            this.targetTarget.innerHTML = "<option>Select language first</option>"
            return
        }

        const url = new URL(this.urlValue, window.location.origin)
        url.searchParams.set("language_id", selectedLanguageId)

        fetch(url, {
            headers: {
                "Accept": "text/vnd.turbo-stream.html"
            }
        })
            .then(r => r.text())
            .then(html => {
                Turbo.renderStreamMessage(html)
            })
    }
}
