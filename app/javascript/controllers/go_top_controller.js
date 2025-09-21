import { Controller } from "@hotwired/stimulus"

// Debounce function to limit how often the scroll event handler runs
function debounce(func, wait) {
    let timeout
    return function(...args) {
        clearTimeout(timeout)
        timeout = setTimeout(() => func.apply(this, args), wait)
    }
}

export default class extends Controller {
    static targets = ["button"]
    static values = {
        threshold: { type: Number, default: 300 } // Default threshold in pixels
    }

    connect() {
        // Hide button initially using classes
        this.buttonTarget.classList.add("opacity-0", "invisible")

        // Use a debounced version of the toggle function for performance
        this.debouncedToggle = debounce(this.toggle, 100).bind(this)
        window.addEventListener("scroll", this.debouncedToggle)
    }

    disconnect() {
        window.removeEventListener("scroll", this.debouncedToggle)
    }

    toggle() {
        if (window.scrollY > this.thresholdValue) {
            // Fade in
            this.buttonTarget.classList.remove("opacity-0", "invisible")
            this.buttonTarget.classList.add("opacity-100", "visible")
        } else {
            // Fade out
            this.buttonTarget.classList.remove("opacity-100", "visible")
            this.buttonTarget.classList.add("opacity-0", "invisible")
        }
    }

    scrollToTop() {
        window.scrollTo({ top: 0, behavior: "smooth" })
    }
}
