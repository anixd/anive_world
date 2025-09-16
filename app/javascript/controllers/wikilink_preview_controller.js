import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.popup = null
        this.showTimer = null
        this.hideTimer = null
        this.currentLink = null
        this.currentMousePosition = { x: 0, y: 0 }

        this.element.addEventListener("mouseenter", this.handleMouseEnter.bind(this), true)
        this.element.addEventListener("mouseleave", this.handleMouseLeave.bind(this), true)
        this.element.addEventListener("mousemove", this.handleMouseMove.bind(this))
    }

    disconnect() {
        this.element.removeEventListener("mouseenter", this.handleMouseEnter)
        this.element.removeEventListener("mouseleave", this.handleMouseLeave)
        this.element.removeEventListener("mousemove", this.handleMouseMove)
        this.cleanup()
    }

    handleMouseEnter(event) {
        const link = event.target.closest(".wikilink")
        if (!link) return

        this.currentMousePosition = { x: event.clientX, y: event.clientY }
        this.cancelTimers()
        this.currentLink = link

        this.showTimer = setTimeout(() => {
            this.fetchPreview(link.dataset.type, link.dataset.slug)
        }, 200)
    }

    handleMouseLeave(event) {
        const link = event.target.closest(".wikilink")
        if (!link) return

        const relatedTarget = event.relatedTarget
        if (relatedTarget && this.popup && this.popup.contains(relatedTarget)) {
            return
        }

        this.cancelTimers()
        this.hideTimer = setTimeout(() => {
            this.hidePopup()
        }, 100)
    }

    handleMouseMove(event) {
        this.currentMousePosition = { x: event.clientX, y: event.clientY }
        if (this.popup) {
            this.positionPopup()
        }
    }

    positionPopup() {
        if (!this.popup || !this.currentMousePosition) return

        const offsetX = 15
        const offsetY = 15
        let x = this.currentMousePosition.x + offsetX
        let y = this.currentMousePosition.y + offsetY
        const popupRect = this.popup.getBoundingClientRect()

        if (x + popupRect.width > window.innerWidth - 10) {
            x = this.currentMousePosition.x - popupRect.width - offsetX
        }
        if (y + popupRect.height > window.innerHeight - 10) {
            y = this.currentMousePosition.y - popupRect.height - offsetY
        }

        this.popup.style.left = `${Math.max(10, x)}px`
        this.popup.style.top = `${Math.max(10, y)}px`
    }

    fetchPreview(type, slug) {
        if (!type || !slug) return

        const url = `/previews/${type}/${slug}`

        fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(response => {
                // Проверяем, что ответ успешный (статус 2xx)
                if (!response.ok) throw new Error("Preview not found or not authorized")
                return response.json()
            })
            .then(data => {
                if (!data || data.error) {
                    this.showPopup(`<div class="wikilink-popup-loading">Не удалось загрузить превью</div>`)
                    return
                }

                // Собираем HTML для всплывающего окна
                // Сначала проверяем, пришел ли URL картинки
                let image_html = data.image_url ? `<img src="${data.image_url}" class="wikilink-popup-image">` : ''

                // собираем остальной контент
                let html = `
                  ${image_html}
                  <div class="wikilink-popup-title">${data.title || ''}</div>
                  ${data.transcription ? `<div class="wikilink-popup-transcription">[${data.transcription}]</div>` : ''}
                  ${data.summary ? `<div class="wikilink-popup-content">${data.summary}</div>` : ''}
                `
                this.showPopup(html)
            })
            .catch((error) => {
                // Эта часть сработает, если запрос провалился (нет сети) или ответ был не-ok
                console.error('Preview fetch error:', error)
                this.showPopup(`<div class="wikilink-popup-error">Превью недоступно</div>`)
            })
    }

    showPopup(content) {
        this.hidePopup()
        this.popup = document.createElement("div")
        this.popup.className = "wikilink-popup"
        this.popup.innerHTML = content
        document.body.appendChild(this.popup)

        this.popup.addEventListener('mouseenter', () => this.cancelTimers())
        this.popup.addEventListener('mouseleave', () => {
            this.hideTimer = setTimeout(() => this.hidePopup(), 500)
        })

        this.positionPopup()
    }

    hidePopup() {
        if (this.popup) {
            this.popup.remove()
            this.popup = null
        }
        this.currentLink = null
    }

    cancelTimers() {
        if (this.showTimer) clearTimeout(this.showTimer)
        if (this.hideTimer) clearTimeout(this.hideTimer)
        this.showTimer = null
        this.hideTimer = null
    }

    cleanup() {
        this.cancelTimers()
        this.hidePopup()
    }
}
