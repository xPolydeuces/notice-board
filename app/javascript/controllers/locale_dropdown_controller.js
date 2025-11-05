import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  hide() {
    this.menuTarget.classList.add("hidden")
  }

  show() {
    this.menuTarget.classList.remove("hidden")
  }

  // Hide dropdown when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  connect() {
    // Store bound function reference to properly remove listener in disconnect
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    // Remove the same function reference that was added in connect
    document.removeEventListener("click", this.boundClickOutside)
  }
}
