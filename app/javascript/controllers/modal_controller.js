import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "backdrop"]

    connect() {
        // Allows closing modal with the Esc key
        this.boundCloseOnEscape = (e) => { if (e.key === "Escape") this.close() }
    }

    open(event) {
        // Prevent default behavior, e.g., for a link or button
        if (event) event.preventDefault()

        this.containerTarget.classList.remove("hidden")
        document.addEventListener("keydown", this.boundCloseOnEscape)
        // Lock body scroll when modal is open
        document.body.classList.add("overflow-hidden")
    }

    close() {
        this.containerTarget.classList.add("hidden")
        document.removeEventListener("keydown", this.boundCloseOnEscape)
        // Unlock body scroll
        document.body.classList.remove("overflow-hidden")
    }

    // Closes the modal if the backdrop (the semi-transparent background) is clicked
    closeOnBackdropClick(event) {
        if (event.target === this.backdropTarget) {
            this.close()
        }
    }

    disconnect() {
        // Ensure the event listener is removed if the controller is disconnected from the DOM
        document.removeEventListener("keydown", this.boundCloseOnEscape)
        document.body.classList.remove("overflow-hidden")
    }
}
