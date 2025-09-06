import { Controller } from "@hotwired/stimulus"

// Никаких специальных импортов из Turbo не нужно!

export default class extends Controller {
    static targets = ["source", "target"]

    update() {
        const selectedLanguageId = this.sourceTarget.value

        // Очищаем и блокируем второй селект, пока ждем ответ
        this.targetTarget.innerHTML = ""
        this.targetTarget.disabled = true

        if (!selectedLanguageId) {
            this.targetTarget.innerHTML = "<option>Сначала выберите язык</option>"
            return
        }

        const url = `/forge/languages/${selectedLanguageId}/parts_of_speech`

        // Используем стандартный fetch с правильным заголовком
        fetch(url, {
            headers: {
                "Accept": "text/vnd.turbo-stream.html"
            }
        })
            .then(r => r.text())
            .then(html => {
                // Turbo.renderStreamMessage обрабатывает полученный HTML
                // и выполняет инструкции <turbo-stream>
                Turbo.renderStreamMessage(html)

                // Разблокируем селект после обновления
                this.targetTarget.disabled = false
            })
    }
}
