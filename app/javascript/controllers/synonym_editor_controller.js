import { Controller } from "@hotwired/stimulus"

function debounce(func, wait) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

export default class extends Controller {
    static targets = ["searchInput", "resultsContainer", "pillsContainer", "hiddenInputsContainer"]

    static values = {
        searchUrl: String,
        initialSynonyms: Array
    }

    connect() {
        this.debouncedSearch = debounce(this.search.bind(this), 300);
        this.hideResultsOnClickOutside = this.hideResultsOnClickOutside.bind(this);
        document.addEventListener("click", this.hideResultsOnClickOutside);
        this.loadInitialSynonyms();
    }

    disconnect() {
        document.removeEventListener("click", this.hideResultsOnClickOutside);
    }

    search() {
        const query = this.searchInputTarget.value.trim();
        if (query.length < 2) {
            this.clearResults();
            return;
        }

        // Pass the `except_id` from the main element's dataset
        const exceptId = this.element.dataset.exceptId;
        const url = new URL(this.searchUrlValue, window.location.origin);
        url.searchParams.set("query", query);
        if (exceptId) {
            url.searchParams.set("except_id", exceptId);
        }

        fetch(url)
            .then(response => response.json())
            .then(data => this.renderResults(data));
    }

    renderResults(data) {
        if (data.length === 0) {
            this.resultsContainerTarget.innerHTML = `<div class="px-4 py-2 text-gray-500">No matches found.</div>`;
        } else {
            this.resultsContainerTarget.innerHTML = data.map(item => `
                <div class="px-4 py-2 cursor-pointer hover:bg-gray-100"
                     data-action="click->synonym-editor#add"
                     data-id="${item.id}" data-text="${item.text}">
                    ${item.text}
                </div>`
            ).join("");
        }
        this.resultsContainerTarget.classList.remove("hidden");
    }

    add(event) {
        const { id, text } = event.currentTarget.dataset;
        if (this.isDuplicate(id)) return;

        this.createPillAndInput(id, text, slug, langCode);
        this.searchInputTarget.value = '';
        this.clearResults();
        this.searchInputTarget.focus();
    }

    remove(event) {
        event.currentTarget.closest('.synonym-pill').remove();
    }

    createPillAndInput(id, text, slug, langCode) {
        const pill = document.createElement('div');
        pill.className = 'synonym-pill bg-blue-100 text-blue-800 px-3 py-1 rounded-full flex items-center gap-2';

        const pillLink = document.createElement('a');
        pillLink.href = `/forge/lexemes/${slug}`;
        pillLink.className = 'wikilink hover:underline';
        pillLink.target = '_blank';
        pillLink.innerText = text;
        pillLink.dataset.type = 'w';
        pillLink.dataset.slug = slug;
        pillLink.dataset.lang = langCode;

        const removeButton = document.createElement('button');
        removeButton.type = 'button';
        removeButton.className = 'font-bold';
        removeButton.dataset.action = 'click->synonym-editor#remove';
        removeButton.innerHTML = '&times;';

        const hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'lexeme[synonym_ids][]';
        hiddenInput.value = id;

        pill.appendChild(pillLink);
        pill.appendChild(removeButton);
        pill.appendChild(hiddenInput);

        this.pillsContainerTarget.appendChild(pill);
    }

    loadInitialSynonyms() {
        if (this.hasInitialSynonymsValue) {
            this.initialSynonymsValue.forEach(synonym => {
                this.createPillAndInput(synonym.id, synonym.text, synonym.slug, synonym.lang_code);
            });
        }
    }

    isDuplicate(id) {
        // Find input with this value inside the container
        return this.pillsContainerTarget.querySelector(`input[value="${id}"]`) !== null;
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
}
