import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs'

// Helper to debounce search requests
function debounce(func, wait) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

export default class extends Controller {
    static targets = ["searchInput", "resultsContainer", "pillsContainer", "hiddenInput", "languageSelect", "spellingInput"]

    static values = {
        searchUrl: String,
        initialMorphemes: Array
    }

    connect() {
        this.debouncedSearch = debounce(this.search.bind(this), 300)
        this.hideResultsOnClickOutside = this.hideResultsOnClickOutside.bind(this)
        document.addEventListener("click", this.hideResultsOnClickOutside)

        this.sortable = new Sortable(this.pillsContainerTarget, {
            animation: 150,
            ghostClass: 'sortable-ghost',
            onEnd: this.onDragEnd.bind(this)
        });

        this.loadInitialMorphemes()
    }

    disconnect() {
        document.removeEventListener("click", this.hideResultsOnClickOutside)
    }

    // earch logic
    search() {
        const query = this.searchInputTarget.value.trim();
        const languageId = this.languageSelectTarget.value;

        if (!languageId) {
            this.resultsContainerTarget.innerHTML = `<div class="px-4 py-2 text-orange-700 bg-orange-100">Please select a language first.</div>`;
            this.resultsContainerTarget.classList.remove("hidden");
            return;
        }

        if (query.length < 1) {
            this.clearResults();
            return;
        }

        const url = new URL(this.searchUrlValue, window.location.origin);
        url.searchParams.set("query", query);
        url.searchParams.set("language_id", languageId);

        fetch(url)
            .then(response => response.json())
            .then(data => this.renderResults(data));
    }

    renderResults(data) {
        if (data.length === 0) {
            this.resultsContainerTarget.innerHTML = `<div class="px-4 py-2 text-gray-500">No matches found.</div>`;
        } else {
            this.resultsContainerTarget.innerHTML = data.map(item => {
                const isRoot = item.type === 'Root';
                const itemClass = isRoot ? 'is-root' : 'is-affix';
                return `
          <div class="px-4 py-2 cursor-pointer hover:bg-gray-100 ${itemClass}"
               data-action="click->morpheme-constructor#add"
               data-id="${item.id}" data-text="${item.text}" data-type="${item.type}">
            ${item.text} <span class="text-xs text-gray-400 uppercase ml-2">${item.type}</span>
          </div>`;
            }).join("");
        }
        this.resultsContainerTarget.classList.remove("hidden");
    }

    // pills management
    add(event) {
        const { id, text, type } = event.currentTarget.dataset;

        // Prevent adding duplicates
        if (this.isDuplicate(id, type)) {
            return;
        }

        this.createPill(id, text, type);
        this.updateHiddenInput();
        this.searchInputTarget.value = '';
        this.clearResults();
        this.searchInputTarget.focus();
    }

    remove(event) {
        event.currentTarget.closest('.morpheme-pill').remove();
        this.updateHiddenInput();
    }

    createPill(id, text, type) {
        const isRoot = type === 'Root';
        const pillClass = isRoot ? 'is-root' : 'is-affix';

        const pill = document.createElement('div');
        pill.className = `morpheme-pill ${pillClass}`;
        pill.dataset.id = id;
        pill.dataset.type = type;
        pill.innerHTML = `
      <span>${text}</span>
      <button type="button" class="ml-2 font-bold" data-action="click->morpheme-constructor#remove">&times;</button>
    `;
        this.pillsContainerTarget.appendChild(pill);
    }

    // drag & drop
    onDragEnd() {
        this.updateHiddenInput();
    }

    // data & state
    updateHiddenInput() {
        const morphemes = Array.from(this.pillsContainerTarget.querySelectorAll('.morpheme-pill')).map((pill, index) => {
            return {
                id: pill.dataset.id,
                type: pill.dataset.type,
                position: index + 1
            };
        });
        this.hiddenInputTarget.value = JSON.stringify(morphemes);
    }

    loadInitialMorphemes() {
        if (this.hasInitialMorphemesValue) {
            this.initialMorphemesValue.forEach(morpheme => {
                this.createPill(morpheme.id, morpheme.text, morpheme.type);
            });
            this.updateHiddenInput();
        }
    }

    isDuplicate(id, type) {
        return Array.from(this.pillsContainerTarget.querySelectorAll('.morpheme-pill'))
            .some(pill => pill.dataset.id === id && pill.dataset.type === type);
    }

    clearResults() {
        this.resultsContainerTarget.innerHTML = "";
        this.resultsContainerTarget.classList.add("hidden");
    }

    hideResultsOnClickOutside(event) {
        if (!this.element.contains(event.target)) {
            this.clearResults();
        }
    }

    async createRootFromSpelling(event) {
        event.preventDefault()
        const spelling = this.spellingInputTarget.value.trim()
        const languageId = this.languageSelectTarget.value

        if (!spelling || !languageId) {
            alert("Please enter a spelling and select a language first.")
            return
        }

        const url = `/forge/languages/${languageId}/roots`
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                root: {
                    text: spelling,
                    language_id: languageId
                }
            })
        })

        const data = await response.json()

        if (response.ok) {
            // Если корень успешно создан, добавляем его как "таблетку"
            if (!this.isDuplicate(data.id, data.type)) {
                this.createPill(data.id, data.text, data.type)
                this.updateHiddenInput()
            }
        } else {
            // Если корень уже существует или другая ошибка
            alert(`Error: ${data.errors.join(', ')}`)
        }
    }
}
