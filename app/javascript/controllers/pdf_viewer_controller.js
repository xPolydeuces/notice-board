import { Controller } from "@hotwired/stimulus"
import * as pdfjsLib from "pdfjs-dist"

// Use CDN for worker (simpler than bundling)
pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.9.155/pdf.worker.min.mjs"

export default class extends Controller {
  static values = {
    url: String,
    duration: { type: Number, default: 30000 } // Total display duration in ms
  }

  connect() {
    this.loadPdf()
  }

  disconnect() {
    this.stopAutoScroll()
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
      const scale = Math.min(containerWidth / viewport.width, 2) // Cap scale at 2x
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
        // Reached the end, stay there
        container.scrollTop = scrollHeight
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