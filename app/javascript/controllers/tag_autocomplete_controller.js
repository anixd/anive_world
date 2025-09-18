import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "results"]
    static values = {
        url: String,
    }

    connect() {
        this.hideResults = this.hideResults.bind(this)
        document.addEventListener("click", this.hideResults, true) // Use capture to handle clicks properly
    }

    disconnect() {
        document.removeEventListener("click", this.hideResults, true)
    }

    // --- Main search function, triggered on keyup ---
    search() {
        const term = this.getCurrentTerm()

        if (term.length < 2) {
            this.clearResults()
            return
        }

        fetch(`${this.urlValue}?query=${encodeURIComponent(term)}`)
            .then(response => response.json())
            .then(tags => {
                this.renderResults(tags)
            })
    }

    // --- Action to select a tag from the results ---
    select(event) {
        event.preventDefault()
        const selectedTag = event.currentTarget.textContent.trim()
        const input = this.inputTarget
        const originalValue = input.value
        const cursorPos = input.selectionStart

        // Find the boundaries of the term we are replacing
        const textBeforeCursor = originalValue.substring(0, cursorPos)
        const startOfTerm = Math.max(textBeforeCursor.lastIndexOf(','), textBeforeCursor.lastIndexOf(' ')) + 1

        const textAfterCursor = originalValue.substring(cursorPos)
        let endOfTermInSuffix = textAfterCursor.indexOf(',')
        if (endOfTermInSuffix === -1) endOfTermInSuffix = textAfterCursor.indexOf(' ')
        if (endOfTermInSuffix === -1) endOfTermInSuffix = textAfterCursor.length

        const endOfTerm = cursorPos + endOfTermInSuffix

        // Reconstruct the input value
        const prefix = originalValue.substring(0, startOfTerm)
        const suffix = originalValue.substring(endOfTerm)

        input.value = `${prefix}${selectedTag}, ${suffix.trim()}`.replace(/\s\s+/, ' ')

        this.clearResults()
        input.focus()

        // Move cursor to after the inserted tag and comma
        const newCursorPos = prefix.length + selectedTag.length + 2 // +2 for ", "
        input.setSelectionRange(newCursorPos, newCursorPos)
    }

    // --- Helper methods ---

    // Extracts the current word/term at the cursor position
    getCurrentTerm() {
        const value = this.inputTarget.value
        const cursorPos = this.inputTarget.selectionStart

        const textBeforeCursor = value.substring(0, cursorPos)
        const lastSeparator = Math.max(textBeforeCursor.lastIndexOf(','), textBeforeCursor.lastIndexOf(' '))

        return textBeforeCursor.substring(lastSeparator + 1).trim()
    }

    renderResults(tags) {
        if (tags.length === 0) {
            this.clearResults()
            return
        }
        const html = tags.map(tag =>
            `<li class="px-4 py-2 hover:bg-gray-100 cursor-pointer" data-action="mousedown->tag-autocomplete#select">${tag}</li>`
        ).join("")
        this.resultsTarget.innerHTML = `<ul class="absolute z-10 w-full bg-white border rounded mt-1 shadow-lg">${html}</ul>`
    }

    clearResults() {
        this.resultsTarget.innerHTML = ""
    }

    hideResults(event) {
        if (!this.element.contains(event.target)) {
            this.clearResults()
        }
    }
}
