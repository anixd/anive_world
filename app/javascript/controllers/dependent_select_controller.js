import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["source", "target"]

    update() {
        const selectedLanguageId = this.sourceTarget.value

        if (!selectedLanguageId) {
            this.targetTarget.innerHTML = "<option>Select language first</option>"
            return
        }

        const url = `/forge/lexemes/parts_of_speech?language_id=${selectedLanguageId}`

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
