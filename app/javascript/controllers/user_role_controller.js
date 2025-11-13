import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["roleSelect", "locationField"]

    connect() {
        this.toggleLocation()
    }

    toggleLocation() {
        const role = this.roleSelectTarget.value

        // Show location field only if role is 'location'
        if (role === 'location') {
            this.locationFieldTarget.classList.remove('hidden')
        } else {
            this.locationFieldTarget.classList.add('hidden')
        }
    }
}