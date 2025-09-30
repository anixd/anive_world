import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["source", "target"]
    static values = { urlTemplate: String }

    update() {
        const selectedLanguageId = this.sourceTarget.value

        if (!selectedLanguageId) {
            this.targetTarget.innerHTML = "<p class='text-gray-500 text-sm'>Select language first</p>"
            return
        }

        const url = this.urlTemplateValue.replace('%3Alang_id', selectedLanguageId);
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
