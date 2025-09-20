import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        this.hideTimer = null
    }

    show() {
        clearTimeout(this.hideTimer)
        this.menuTarget.classList.remove('hidden')
    }

    hide() {
        this.hideTimer = setTimeout(() => {
            this.menuTarget.classList.add('hidden')
        }, 200) // 200ms задержка перед закрытием
    }
}
