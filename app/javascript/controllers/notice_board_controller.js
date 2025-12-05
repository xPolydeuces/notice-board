import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["carousel", "slide", "dots", "marquee", "marqueeContent"]
  static values = {
    interval: { type: Number, default: 10000 }, // 10 seconds
    refreshInterval: { type: Number, default: 300000 } // 5 minutes
  }

  connect() {
    this.initializeCarousels()
    this.initializeMarquee()
    this.scheduleRefresh()
  }

  disconnect() {
    this.stopCarousels()
    this.stopMarquee()
    if (this.refreshTimeout) clearTimeout(this.refreshTimeout)
  }

  initializeCarousels() {
    this.carouselTargets.forEach(carousel => {
      const slides = carousel.querySelectorAll('[data-slide]')
      if (slides.length <= 1) return

      let currentIndex = 0
      const dots = carousel.querySelector('[data-dots]')

      const showSlide = (index) => {
        slides.forEach((slide, i) => {
          const wasActive = slide.classList.contains('opacity-100')
          const isActive = i === index
          slide.classList.toggle('opacity-0', !isActive)
          slide.classList.toggle('opacity-100', isActive)

          // Dispatch event when slide becomes active
          if (isActive && !wasActive) {
            slide.dispatchEvent(new CustomEvent('slide:active', { bubbles: true }))
          }
        })

        if (dots) {
          const dotElements = dots.querySelectorAll('[data-dot]')
          dotElements.forEach((dot, i) => {
            if (i === index) {
              dot.classList.remove('bg-orange-300')
              dot.classList.add('bg-orange-600')
            } else {
              dot.classList.remove('bg-orange-600')
              dot.classList.add('bg-orange-300')
            }
          })
        }
      }

      const scheduleNextSlide = () => {
        const currentSlide = slides[currentIndex]
        const duration = parseInt(currentSlide.dataset.duration) || this.intervalValue

        carousel.carouselTimeout = setTimeout(() => {
          currentIndex = (currentIndex + 1) % slides.length
          showSlide(currentIndex)
          scheduleNextSlide()
        }, duration)
      }

      scheduleNextSlide()
    })
  }

  stopCarousels() {
    this.carouselTargets.forEach(carousel => {
      if (carousel.carouselTimeout) {
        clearTimeout(carousel.carouselTimeout)
      }
    })
  }

  initializeMarquee() {
    if (!this.hasMarqueeTarget || !this.hasMarqueeContentTarget) return

    const marquee = this.marqueeTarget
    const content = this.marqueeContentTarget

    // Create clones for seamless loop
    if (!marquee.dataset.cloned) {
      for (let i = 0; i < 3; i++) {
      marquee.appendChild(content.cloneNode(true))
      }
      marquee.dataset.cloned = 'true'
    }

    let position = 0
    const speed = 2.5

    const animate = () => {
      position -= speed
      if (Math.abs(position) >= content.offsetWidth) {
        position = 0
      }
      marquee.style.transform = `translateX(${position}px)`
      this.marqueeFrame = requestAnimationFrame(animate)
    }

    animate()
  }

  stopMarquee() {
    if (this.marqueeFrame) {
      cancelAnimationFrame(this.marqueeFrame)
    }
  }

  scheduleRefresh() {
    this.refreshTimeout = setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: 'replace' })
    }, this.refreshIntervalValue)
  }
}