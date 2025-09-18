import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from '@hotwired/turbo'

function debounce(func, wait) {
    let timeout
    return function(...args) {
        const context = this
        clearTimeout(timeout)
        timeout = setTimeout(() => func.apply(context, args), wait)
    }
}

export default class extends Controller {
    static targets = ["input", "resultsContainer", "form", "loreTab", "dictionaryTab", "scopeInput"]
    static values = {
        scope: String,
        searchUrl: String
    }

    connect() {
        this.debouncedSearch = debounce(this.performSearch, 300).bind(this)
        // Set initial scope from params or default
        if (!this.scopeValue) {
            this.scopeValue = 'lore'
        }
        this.updateTabStyles()
        this.updatePlaceholder()
    }

    // Called when typing in the input
    search() {
        // For now, do nothing - we'll implement live search later
        // this.debouncedSearch()
    }

    // Called when a tab is clicked
    setScope(event) {
        event.preventDefault()
        const newScope = event.currentTarget.dataset.scope

        if (this.scopeValue !== newScope) {
            this.scopeValue = newScope
            this.scopeInputTarget.value = newScope
            this.updateTabStyles()
            this.updatePlaceholder()

            // NO automatic form submission - user must press Enter or click Search
            // Just update the hidden field value for when they do search
        }
    }

    updateTabStyles() {
        const isLore = this.scopeValue === 'lore'

        // Update Lore tab
        this.loreTabTarget.className = `flex-1 py-2 px-4 text-center font-medium transition-colors ${
            isLore ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
        }`

        // Update Dictionary tab
        this.dictionaryTabTarget.className = `flex-1 py-2 px-4 text-center font-medium transition-colors ${
            !isLore ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
        }`
    }

    updatePlaceholder() {
        this.inputTarget.placeholder = this.scopeValue === 'dictionary'
            ? "Search in Dictionary..."
            : "Search in Lore..."
    }

    performSearch() {
        // Will implement later for live search
    }

    // Clear results when clicking outside
    clearResults() {
        this.resultsContainerTarget.innerHTML = ''
    }
}
