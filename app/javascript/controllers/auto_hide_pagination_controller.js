import { Controller } from "@hotwired/stimulus"

// data-controller="auto-hide-pagination"
// data-auto-hide-pagination-target="list"
// data-auto-hide-pagination-target="bottom"
export default class extends Controller {
    static targets = ["list", "bottom"]

    connect() {
        this.onResize = () => this.evaluate()
        this.evaluate()
        window.addEventListener("resize", this.onResize)
    }

    disconnect() {
        window.removeEventListener("resize", this.onResize)
    }

    evaluate() {
        if (!this.hasListTarget || !this.hasBottomTarget) return

        const fudge = 48 // запас в px, чтобы «+1–2 элемента» тоже считались как «не нужно»
        const listHeight = this.listTarget.scrollHeight
        const vp = window.innerHeight

        if (listHeight + fudge <= vp) {
            this.bottomTarget.classList.add("hidden")
        } else {
            this.bottomTarget.classList.remove("hidden")
        }
    }
}

