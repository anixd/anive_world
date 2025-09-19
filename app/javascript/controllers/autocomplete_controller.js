import { Controller } from "@hotwired/stimulus"

function debounce(func, wait) {
    let timeout
    return function(...args) {
        const context = this
        clearTimeout(timeout)
        timeout = setTimeout(() => func.apply(context, args), wait)
    }
}

export default class extends Controller {
    static targets = ["input", "hiddenInput", "results", "clearButton"]
    static values = {
        url: String,
        exceptId: String
    }

    connect() {
        this.debouncedSearch = debounce(this.search, 300).bind(this)
        this.hideResultsOnClickOutside = this.hideResultsOnClickOutside.bind(this)
        document.addEventListener("click", this.hideResultsOnClickOutside)

        // If the form is for an existing record with a value, show the clear button
        this.toggleClearButton()
    }

    disconnect() {
        document.removeEventListener("click", this.hideResultsOnClickOutside)
    }

    search() {
        const query = this.inputTarget.value.trim()
        if (query.length < 2) {
            this.clearResults()
            return
        }

        const url = new URL(this.urlValue, window.location.origin)
        url.searchParams.set("query", query)
        if (this.hasExceptIdValue) {
            url.searchParams.set("except_id", this.exceptIdValue)
        }

        fetch(url)
            .then(response => response.json())
            .then(data => {
                this.renderResults(data)
            })
    }

    renderResults(data) {
        if (data.length === 0) {
            this.resultsTarget.innerHTML = `<div class="px-4 py-2 text-gray-500">No matches found.</div>`
        } else {
            this.resultsTarget.innerHTML = data.map(item =>
                `<div class="px-4 py-2 hover:bg-blue-500 hover:text-white cursor-pointer" data-action="click->autocomplete#select" data-id="${item.id}" data-text="${item.text}">
                    ${item.text}
                </div>`
            ).join("")
        }
        this.resultsTarget.classList.remove("hidden")
    }

    select(event) {
        const selectedItem = event.currentTarget
        this.hiddenInputTarget.value = selectedItem.dataset.id
        this.inputTarget.value = selectedItem.dataset.text
        this.clearResults()
        this.toggleClearButton()
    }

    clear(event) {
        event.preventDefault()
        this.hiddenInputTarget.value = ""
        this.inputTarget.value = ""
        this.clearResults()
        this.toggleClearButton()
    }

    clearResults() {
        this.resultsTarget.innerHTML = ""
        this.resultsTarget.classList.add("hidden")
    }

    toggleClearButton() {
        this.clearButtonTarget.classList.toggle("hidden", !this.hiddenInputTarget.value)
    }

    hideResultsOnClickOutside(event) {
        if (!this.element.contains(event.target)) {
            this.clearResults()
        }
    }
}
