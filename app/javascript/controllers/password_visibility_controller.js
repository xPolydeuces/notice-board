import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "eyeOpen", "eyeClosed"]

  toggle() {
    if (this.inputTarget.type === "password") {
      this.inputTarget.type = "text"
      this.eyeOpenTarget.classList.add("hidden")
      this.eyeClosedTarget.classList.remove("hidden")
    } else {
      this.inputTarget.type = "password"
      this.eyeOpenTarget.classList.remove("hidden")
      this.eyeClosedTarget.classList.add("hidden")
    }
  }
}