import { Controller } from "@hotwired/stimulus"

// data-controller="per-page"
// <select data-action="change->per-page#change">...</select>
export default class extends Controller {
    static values = { param: { type: String, default: "per" } }

    change(event) {
        const per = event.target.value
        const url = new URL(window.location.href)
        url.searchParams.set(this.paramValue, per)
        url.searchParams.set("page", 1)
        window.location.assign(url.toString())
    }
}
