import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "generalBox", "locationBox", "trigger", "locationList", "locationArrow", "currentLocation"]
  static values = {
    mode: { type: String, default: "default" }
  }

  connect() {
    // Load saved mode from localStorage
    const savedMode = localStorage.getItem('displayMode')
    if (savedMode) {
      this.modeValue = savedMode
      this.applyMode(savedMode, false)
    }

    // Add keyboard listener for 'm' key
    this.keyListener = this.handleKeyPress.bind(this)
    document.addEventListener('keydown', this.keyListener)
  }

  disconnect() {
    document.removeEventListener('keydown', this.keyListener)
  }

  handleKeyPress(event) {
    // Press 'm' to toggle menu
    if (event.key === 'm' || event.key === 'M') {
      this.toggleMenu()
    }
    // Press 'Escape' to close menu
    if (event.key === 'Escape' && this.hasMenuTarget) {
      this.closeMenu()
    }
  }

  toggleMenu() {
    if (this.hasMenuTarget) {
      const isHidden = this.menuTarget.classList.contains('hidden')
      if (isHidden) {
        this.openMenu()
      } else {
        this.closeMenu()
      }
    }
  }

  openMenu() {
    this.menuTarget.classList.remove('hidden')
    this.menuTarget.classList.add('flex')
    // Add animation
    setTimeout(() => {
      this.menuTarget.classList.remove('opacity-0', 'scale-95')
      this.menuTarget.classList.add('opacity-100', 'scale-100')
    }, 10)
  }

  closeMenu() {
    this.menuTarget.classList.remove('opacity-100', 'scale-100')
    this.menuTarget.classList.add('opacity-0', 'scale-95')
    // Wait for animation before hiding
    setTimeout(() => {
      this.menuTarget.classList.remove('flex')
      this.menuTarget.classList.add('hidden')
      // Also hide location list when closing menu
      if (this.hasLocationListTarget) {
        this.locationListTarget.classList.add('hidden')
        this.locationArrowTarget.classList.remove('rotate-180')
      }
    }, 200)
  }

  setMode(event) {
    event.stopPropagation()
    const mode = event.currentTarget.dataset.mode
    this.applyMode(mode, true)
    this.closeMenu()
  }

  applyMode(mode, animate = true) {
    this.modeValue = mode
    localStorage.setItem('displayMode', mode)

    const generalBox = this.generalBoxTarget
    const locationBox = this.locationBoxTarget

    // Remove all mode classes
    const removeClass = (element) => {
      element.classList.remove('hidden', 'lg:flex-[65]', 'lg:flex-[35]', 'flex-[100]')
    }

    removeClass(generalBox)
    removeClass(locationBox)

    // Apply transition classes if animate
    if (animate) {
      generalBox.style.transition = 'all 0.5s ease-in-out'
      locationBox.style.transition = 'all 0.5s ease-in-out'
    }

    switch (mode) {
      case 'general-only':
        // Show only general box in fullscreen
        generalBox.classList.add('flex-[100]')
        locationBox.classList.add('hidden')
        break

      case 'location-only':
        // Show only location box in fullscreen
        generalBox.classList.add('hidden')
        locationBox.classList.add('flex-[100]')
        break

      case 'default':
      default:
        // Show both boxes (default layout)
        generalBox.classList.add('lg:flex-[65]')
        locationBox.classList.add('lg:flex-[35]')
        break
    }

    // Remove transition after animation
    if (animate) {
      setTimeout(() => {
        generalBox.style.transition = ''
        locationBox.style.transition = ''
      }, 500)
    }
  }

  // Trigger area click handler
  openMenuFromTrigger(event) {
    event.preventDefault()
    this.openMenu()
  }

  // Prevent clicks inside menu from closing it
  preventClose(event) {
    event.stopPropagation()
  }

  // Toggle location list visibility
  toggleLocationList(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.hasLocationListTarget && this.hasLocationArrowTarget) {
      const isHidden = this.locationListTarget.classList.contains('hidden')

      if (isHidden) {
        this.locationListTarget.classList.remove('hidden')
        this.locationArrowTarget.classList.add('rotate-180')
      } else {
        this.locationListTarget.classList.add('hidden')
        this.locationArrowTarget.classList.remove('rotate-180')
      }
    }
  }

  // Select a location and reload page with location_id parameter
  selectLocation(event) {
    event.preventDefault()
    event.stopPropagation()
    const locationId = event.currentTarget.dataset.locationId
    const locationName = event.currentTarget.dataset.locationName

    if (locationId) {
      // Update URL with location_id parameter and reload
      const url = new URL(window.location)
      url.searchParams.set('location_id', locationId)
      window.location.href = url.toString()
    }
  }

  // Clear location selection and reload page without location_id
  clearLocation(event) {
    event.preventDefault()
    event.stopPropagation()

    // Remove location_id parameter from URL and reload
    const url = new URL(window.location)
    url.searchParams.delete('location_id')
    window.location.href = url.toString()
  }
}