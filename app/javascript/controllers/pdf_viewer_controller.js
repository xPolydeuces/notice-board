import { Controller } from "@hotwired/stimulus"
import * as pdfjsLib from "pdfjs-dist"

// Use CDN for worker (must match pdfjs-dist version in package.json)
pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.10.38/pdf.worker.min.mjs"

export default class extends Controller {
  static values = {
    url: String,
    duration: { type: Number, default: 30000 } // Total display duration in ms
  }

  connect() {
    this.handleSlideActive = this.resetAndPlay.bind(this)
    this.element.addEventListener('slide:active', this.handleSlideActive)

    // Listen for responsive scale updates
    this.handleResponsiveScale = this.onResponsiveScale.bind(this)
    this.element.addEventListener('responsive-scale:update', this.handleResponsiveScale)

    this.loadPdf()
  }

  disconnect() {
    this.stopAutoScroll()
    this.element.removeEventListener('slide:active', this.handleSlideActive)
    this.element.removeEventListener('responsive-scale:update', this.handleResponsiveScale)
  }

  onResponsiveScale(event) {
    // Only re-render if PDF is already loaded
    if (this.pdf && this.rendered) {
      this.reRenderPdf()
    }
  }

  resetAndPlay() {
    if (!this.rendered) return
    this.stopAutoScroll()
    this.element.scrollTop = 0
    this.startAutoScroll()
  }

  async loadPdf() {
    try {
      // Show loading state
      this.element.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">Loading PDF...</div>'

      const loadingTask = pdfjsLib.getDocument({
        url: this.urlValue,
        disableWorker: true
      })
      this.pdf = await loadingTask.promise

      // Clear loading state
      this.element.innerHTML = ''

      await this.renderAllPages()
      this.rendered = true
      this.startAutoScroll()
    } catch (error) {
      console.error("Error loading PDF:", error)
      this.element.innerHTML = `<div class="flex items-center justify-center h-full text-red-500">Failed to load PDF</div>`
    }
  }

  async renderAllPages() {
    const container = this.element

    // Calculate scale to fit width, with some padding
    const containerWidth = container.clientWidth - 40

    for (let pageNum = 1; pageNum <= this.pdf.numPages; pageNum++) {
      const page = await this.pdf.getPage(pageNum)
      const viewport = page.getViewport({ scale: 1 })
      const scale = containerWidth / viewport.width
      const scaledViewport = page.getViewport({ scale })

      const canvas = document.createElement("canvas")
      canvas.className = "mx-auto mb-4 shadow-md block"
      canvas.width = scaledViewport.width
      canvas.height = scaledViewport.height

      const context = canvas.getContext("2d")
      await page.render({
        canvasContext: context,
        viewport: scaledViewport
      }).promise

      container.appendChild(canvas)
    }
  }

  async reRenderPdf() {
    // Save current scroll position as percentage
    const scrollPercentage = this.element.scrollTop / (this.element.scrollHeight - this.element.clientHeight)

    // Stop any ongoing auto-scroll
    this.stopAutoScroll()

    // Clear existing canvases
    this.element.innerHTML = ''

    // Re-render all pages with new scale
    await this.renderAllPages()

    // Restore scroll position (approximately)
    const newScrollHeight = this.element.scrollHeight - this.element.clientHeight
    if (newScrollHeight > 0 && !isNaN(scrollPercentage)) {
      this.element.scrollTop = scrollPercentage * newScrollHeight
    }

    // Restart auto-scroll if this is the active slide
    // Check if parent has 'opacity-100' class (active slide indicator)
    const slideElement = this.element.closest('[data-notice-board-target="slide"]')
    if (slideElement && slideElement.classList.contains('opacity-100')) {
      this.startAutoScroll()
    }
  }

  startAutoScroll() {
    const container = this.element
    const scrollHeight = container.scrollHeight - container.clientHeight

    if (scrollHeight <= 0) return // No need to scroll

    // Calculate scroll speed based on duration
    // Leave 2 seconds at start and end for readability
    const scrollDuration = this.durationValue - 4000
    if (scrollDuration <= 0) return

    const scrollSpeed = scrollHeight / scrollDuration // pixels per ms

    let startTime = null
    const pauseAtStart = 2000 // 2 second pause at start
    const pauseAtEnd = 2000   // 2 second pause at end

    const animate = (timestamp) => {
      if (!startTime) startTime = timestamp
      const elapsed = timestamp - startTime

      if (elapsed < pauseAtStart) {
        // Pause at start
        this.animationFrame = requestAnimationFrame(animate)
        return
      }

      const scrollTime = elapsed - pauseAtStart

      if (scrollTime >= scrollDuration) {
        // Reached the end, pause then loop
        container.scrollTop = scrollHeight

        const totalDuration = pauseAtStart + scrollDuration + pauseAtEnd
        if (elapsed >= totalDuration) {
          // Reset and restart the loop
          container.scrollTop = 0
          startTime = null
        }
        this.animationFrame = requestAnimationFrame(animate)
        return
      }

      container.scrollTop = scrollTime * scrollSpeed
      this.animationFrame = requestAnimationFrame(animate)
    }

    this.animationFrame = requestAnimationFrame(animate)
  }

  stopAutoScroll() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
    }
  }
}