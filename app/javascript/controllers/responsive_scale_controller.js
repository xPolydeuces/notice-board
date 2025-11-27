import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = {
    debounceDelay: { type: Number, default: 150 }
  }

  connect() {
    this.resizeObserver = null
    this.debounceTimer = null
    this.previousWidth = window.innerWidth
    this.previousHeight = window.innerHeight

    // Use ResizeObserver for better performance than window.resize
    if ('ResizeObserver' in window) {
      this.resizeObserver = new ResizeObserver(entries => {
        this.handleResize()
      })
      this.resizeObserver.observe(document.body)
    } else {
      // Fallback to window resize event
      this.boundHandleResize = this.handleResize.bind(this)
      window.addEventListener('resize', this.boundHandleResize)
    }

    // Also listen for fullscreen changes
    this.boundHandleFullscreenChange = this.handleResize.bind(this)
    document.addEventListener('fullscreenchange', this.boundHandleFullscreenChange)
    document.addEventListener('webkitfullscreenchange', this.boundHandleFullscreenChange)
    document.addEventListener('mozfullscreenchange', this.boundHandleFullscreenChange)
    document.addEventListener('msfullscreenchange', this.boundHandleFullscreenChange)

    // Initial scale
    this.updateScale()
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }

    if (this.boundHandleResize) {
      window.removeEventListener('resize', this.boundHandleResize)
    }

    document.removeEventListener('fullscreenchange', this.boundHandleFullscreenChange)
    document.removeEventListener('webkitfullscreenchange', this.boundHandleFullscreenChange)
    document.removeEventListener('mozfullscreenchange', this.boundHandleFullscreenChange)
    document.removeEventListener('msfullscreenchange', this.boundHandleFullscreenChange)

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  handleResize() {
    // Debounce resize events
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      const currentWidth = window.innerWidth
      const currentHeight = window.innerHeight

      // Only update if size actually changed (avoid unnecessary updates)
      if (currentWidth !== this.previousWidth || currentHeight !== this.previousHeight) {
        this.previousWidth = currentWidth
        this.previousHeight = currentHeight
        this.updateScale()
      }
    }, this.debounceDelayValue)
  }

  updateScale() {
    // Dispatch custom event for other controllers to listen to
    const event = new CustomEvent('responsive-scale:update', {
      detail: {
        width: window.innerWidth,
        height: window.innerHeight,
        isFullscreen: this.isFullscreen()
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)

    // Update CSS custom properties for dynamic scaling
    this.updateCSSVariables()

    // Force layout recalculation for images
    this.scaleImages()
  }

  updateCSSVariables() {
    const root = document.documentElement
    const width = window.innerWidth
    const height = window.innerHeight

    // Calculate scale factors based on viewport size
    // Base sizes: 1920x1080 (common display resolution)
    const widthScale = width / 1920
    const heightScale = height / 1080
    const minScale = Math.min(widthScale, heightScale)

    root.style.setProperty('--viewport-width', `${width}px`)
    root.style.setProperty('--viewport-height', `${height}px`)
    root.style.setProperty('--scale-factor', minScale)
    root.style.setProperty('--width-scale', widthScale)
    root.style.setProperty('--height-scale', heightScale)
  }

  scaleImages() {
    // Trigger re-layout for images with object-contain
    const images = this.element.querySelectorAll('img')
    images.forEach(img => {
      // Force browser to recalculate image dimensions
      if (img.complete) {
        img.style.maxWidth = '100%'
        img.style.maxHeight = '100%'
      }
    })
  }

  isFullscreen() {
    return !!(
      document.fullscreenElement ||
      document.webkitFullscreenElement ||
      document.mozFullScreenElement ||
      document.msFullscreenElement
    )
  }
}