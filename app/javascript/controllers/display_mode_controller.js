import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "generalBox", "locationBox", "trigger", "locationList", "locationArrow", "currentLocation"]
  static values = {
    mode: { type: String, default: "default" },
    theme: { type: String, default: "default" },
    autoTheme: { type: Boolean, default: false }
  }

  connect() {
    // Load saved mode from localStorage
    const savedMode = localStorage.getItem('displayMode')
    if (savedMode) {
      this.modeValue = savedMode
      this.applyMode(savedMode, false)
    }

    // Load saved auto-theme setting
    const savedAutoTheme = localStorage.getItem('autoTheme') === 'true'
    this.autoThemeValue = savedAutoTheme

    if (savedAutoTheme) {
      // Apply time-based theme immediately
      this.applyAutoTheme()
      // Start interval to check time periodically
      this.startAutoThemeInterval()
    } else {
      // Load saved theme from localStorage
      const savedTheme = localStorage.getItem('displayTheme') || 'default'
      this.themeValue = savedTheme
      this.applyTheme(savedTheme)
    }

    // Add keyboard listener for 'm' key
    this.keyListener = this.handleKeyPress.bind(this)
    document.addEventListener('keydown', this.keyListener)

    // Update auto-theme button state after a brief delay to ensure DOM is ready
    setTimeout(() => this.updateAutoThemeButton(), 100)
  }

  disconnect() {
    document.removeEventListener('keydown', this.keyListener)
    this.stopAutoThemeInterval()
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

  // Select a location and use Turbo for client-side navigation
  selectLocation(event) {
    event.preventDefault()
    event.stopPropagation()
    const locationId = event.currentTarget.dataset.locationId
    const locationName = event.currentTarget.dataset.locationName

    if (locationId) {
      // Close menu first for better UX
      this.closeMenu()

      // Update URL with location_id parameter and use Turbo for smooth client-side navigation
      const url = new URL(window.location)
      url.searchParams.set('location_id', locationId)

      // Use Turbo.visit for seamless navigation without full page reload
      if (typeof Turbo !== 'undefined') {
        Turbo.visit(url.toString(), { action: 'replace' })
      } else {
        window.location.href = url.toString()
      }
    }
  }

  // Clear location selection and use Turbo for client-side navigation
  clearLocation(event) {
    event.preventDefault()
    event.stopPropagation()

    // Close menu first for better UX
    this.closeMenu()

    // Remove location_id parameter from URL and use Turbo for smooth client-side navigation
    const url = new URL(window.location)
    url.searchParams.delete('location_id')

    // Use Turbo.visit for seamless navigation without full page reload
    if (typeof Turbo !== 'undefined') {
      Turbo.visit(url.toString(), { action: 'replace' })
    } else {
      window.location.href = url.toString()
    }
  }

  // Theme switching methods
  setTheme(event) {
    event.stopPropagation()
    const theme = event.currentTarget.dataset.theme
    this.applyTheme(theme)
    this.closeMenu()
  }

  applyTheme(theme) {
    this.themeValue = theme
    localStorage.setItem('displayTheme', theme)

    // Get the main container (body or notice-board-gradient)
    const container = document.querySelector('.notice-board-gradient') || document.body

    // Remove all theme classes
    container.classList.remove('theme-default', 'theme-dark', 'theme-light', 'theme-contrast')

    // Add new theme class
    container.classList.add(`theme-${theme}`)
  }

  // Auto-theme methods
  getTimeBasedTheme() {
    const hour = new Date().getHours()
    // Light theme from 6 AM to 8 PM, Dark theme from 8 PM to 6 AM
    return (hour >= 6 && hour < 20) ? 'light' : 'dark'
  }

  applyAutoTheme() {
    const theme = this.getTimeBasedTheme()
    this.themeValue = theme

    const container = document.querySelector('.notice-board-gradient') || document.body
    container.classList.remove('theme-default', 'theme-dark', 'theme-light', 'theme-contrast')
    container.classList.add(`theme-${theme}`)
  }

  startAutoThemeInterval() {
    // Check every minute for theme changes
    this.autoThemeInterval = setInterval(() => {
      if (this.autoThemeValue) {
        this.applyAutoTheme()
      }
    }, 60000) // 60000ms = 1 minute
  }

  stopAutoThemeInterval() {
    if (this.autoThemeInterval) {
      clearInterval(this.autoThemeInterval)
      this.autoThemeInterval = null
    }
  }

  toggleAutoTheme(event) {
    event.stopPropagation()

    if (this.autoThemeValue) {
      // Disable auto-theme
      this.disableAutoTheme()
    } else {
      // Enable auto-theme
      this.enableAutoTheme()
    }
  }

  enableAutoTheme() {
    this.autoThemeValue = true
    localStorage.setItem('autoTheme', 'true')

    // Apply time-based theme immediately
    this.applyAutoTheme()

    // Start checking time periodically
    this.startAutoThemeInterval()

    // Update UI button state
    this.updateAutoThemeButton()
  }

  disableAutoTheme() {
    this.autoThemeValue = false
    localStorage.setItem('autoTheme', 'false')

    // Stop checking time
    this.stopAutoThemeInterval()

    // Restore last manually selected theme or default
    const savedTheme = localStorage.getItem('displayTheme') || 'default'
    this.applyTheme(savedTheme)

    // Update UI button state
    this.updateAutoThemeButton()
  }

  updateAutoThemeButton() {
    const button = document.querySelector('[data-action="click->display-mode#toggleAutoTheme"]')
    if (button) {
      const statusText = button.querySelector('[data-auto-theme-status]')
      const icon = button.querySelector('[data-auto-theme-icon]')

      if (this.autoThemeValue) {
        button.classList.remove('bg-gray-500', 'hover:bg-gray-600')
        button.classList.add('bg-indigo-500', 'hover:bg-indigo-600')
        if (statusText) statusText.textContent = 'Włączony'
        if (icon) icon.textContent = '🌓'
      } else {
        button.classList.remove('bg-indigo-500', 'hover:bg-indigo-600')
        button.classList.add('bg-gray-500', 'hover:bg-gray-600')
        if (statusText) statusText.textContent = 'Wyłączony'
        if (icon) icon.textContent = '🕐'
      }
    }
  }
}