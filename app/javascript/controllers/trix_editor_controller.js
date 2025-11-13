import { Controller } from "@hotwired/stimulus"
import { icons } from "lucide"

// Connects to data-controller="trix-editor"
export default class extends Controller {
  static targets = ["editor", "counter", "saveStatus"]
  static values = {
    autosave: { type: Boolean, default: true },
    autosaveInterval: { type: Number, default: 30000 }, // 30 seconds
    maxLength: { type: Number, default: 50000 }
  }

  connect() {
    this.setupEditor()
  }

  disconnect() {
    this.clearAutoSave()
  }

  setupEditor() {
    // Store reference to Trix editor element
    this.trixEditor = this.editorTarget

    // Wait for Trix to be fully initialized before setting up enhancements
    this.trixEditor.addEventListener("trix-initialize", () => {
      this.createToolbarEnhancements()
      this.createCounter()
      this.updateCounter()
      this.setupAutoSave()
      this.setupFileUploadHandler()
      this.setupKeyboardShortcuts()
    })

    // Listen to Trix events
    this.trixEditor.addEventListener("trix-change", this.handleChange.bind(this))
    this.trixEditor.addEventListener("trix-selection-change", this.handleSelectionChange.bind(this))
    this.trixEditor.addEventListener("trix-file-accept", this.handleFileAccept.bind(this))
    this.trixEditor.addEventListener("trix-attachment-add", this.handleAttachmentAdd.bind(this))
    this.trixEditor.addEventListener("trix-attachment-remove", this.handleAttachmentRemove.bind(this))
  }

  createToolbarEnhancements() {
    // Get the toolbar
    const toolbar = this.trixEditor.toolbarElement
    if (!toolbar) return

    // Add custom button group for additional features
    const buttonGroup = toolbar.querySelector(".trix-button-group")
    if (buttonGroup) {
      // Add a visual separator
      const separator = document.createElement("span")
      separator.className = "trix-button-group-spacer"
      buttonGroup.parentElement.appendChild(separator)

      // Create new button group for custom actions
      const customGroup = document.createElement("span")
      customGroup.className = "trix-button-group trix-button-group--custom"
      buttonGroup.parentElement.appendChild(customGroup)

      // Add clear formatting button
      this.addClearFormattingButton(customGroup)
    }
  }

  addClearFormattingButton(container) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "trix-button trix-button--icon trix-button--icon-clear"
    button.title = "Wyczyść formatowanie (Clear formatting)"
    button.tabIndex = -1

    // Add Lucide Eraser icon
    const iconPath = icons['eraser']
    if (iconPath) {
      const iconSVG = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">${iconPath}</svg>`
      button.innerHTML = iconSVG
    }

    button.addEventListener("click", this.clearFormatting.bind(this))
    container.appendChild(button)
  }

  clearFormatting() {
    if (!this.trixEditor || !this.trixEditor.editor) return

    const editor = this.trixEditor.editor
    const selectedRange = editor.getSelectedRange()

    if (selectedRange[0] === selectedRange[1]) {
      // No selection, clear all formatting
      editor.recordUndoEntry("Clear Formatting")
      const range = [0, editor.getDocument().toString().length]
      editor.setSelectedRange(range)
    }

    // Remove all attributes
    const attributes = ["bold", "italic", "strike", "link", "heading1", "quote", "code", "bullet", "number"]
    attributes.forEach(attr => {
      editor.deactivateAttribute(attr)
    })
  }

  createCounter() {
    // Check if counter element already exists
    if (this.hasCounterTarget) return

    // Create counter display
    const counterDiv = document.createElement("div")
    counterDiv.className = "trix-counter text-sm text-gray-500 mt-2 flex justify-between items-center"
    counterDiv.dataset.trixEditorTarget = "counter"

    counterDiv.innerHTML = `
      <div class="flex gap-4">
        <span class="word-count">
          <strong>Słowa:</strong> <span class="count">0</span>
        </span>
        <span class="character-count">
          <strong>Znaki:</strong> <span class="count">0</span><span class="max">${this.maxLengthValue > 0 ? ` / ${this.maxLengthValue}` : ''}</span>
        </span>
      </div>
      <div class="save-status" data-trix-editor-target="saveStatus"></div>
    `

    // Insert after the editor
    this.trixEditor.parentElement.appendChild(counterDiv)
  }

  updateCounter() {
    if (!this.hasCounterTarget) return
    if (!this.trixEditor || !this.trixEditor.editor) return

    const text = this.trixEditor.editor.getDocument().toString()
    const wordCount = this.countWords(text)
    const charCount = text.length

    // Update counts
    const wordCountElement = this.counterTarget.querySelector(".word-count .count")
    const charCountElement = this.counterTarget.querySelector(".character-count .count")

    if (wordCountElement) wordCountElement.textContent = wordCount
    if (charCountElement) {
      charCountElement.textContent = charCount

      // Add warning if approaching max length
      if (this.maxLengthValue > 0) {
        if (charCount > this.maxLengthValue * 0.9) {
          charCountElement.classList.add("text-orange-600", "font-semibold")
        } else {
          charCountElement.classList.remove("text-orange-600", "font-semibold")
        }

        if (charCount > this.maxLengthValue) {
          charCountElement.classList.add("text-red-600", "font-bold")
          charCountElement.classList.remove("text-orange-600")
        } else {
          charCountElement.classList.remove("text-red-600", "font-bold")
        }
      }
    }
  }

  countWords(text) {
    // Remove extra whitespace and count words
    const trimmed = text.trim()
    if (trimmed.length === 0) return 0
    return trimmed.split(/\s+/).length
  }

  handleChange(event) {
    this.updateCounter()
    this.markAsModified()
  }

  handleSelectionChange(event) {
    // Can be used for additional features like showing formatting info
  }

  // Auto-save functionality
  setupAutoSave() {
    if (!this.autosaveValue) return

    this.autoSaveTimer = null
    this.lastSaved = Date.now()
    this.modified = false
  }

  clearAutoSave() {
    if (this.autoSaveTimer) {
      clearTimeout(this.autoSaveTimer)
      this.autoSaveTimer = null
    }
  }

  markAsModified() {
    this.modified = true
    this.clearAutoSave()

    // Schedule auto-save
    if (this.autosaveValue) {
      this.autoSaveTimer = setTimeout(() => {
        this.autoSave()
      }, this.autosaveIntervalValue)
    }
  }

  autoSave() {
    if (!this.modified) return

    this.updateSaveStatus("Zapisywanie...", "text-blue-600")

    // Trigger a custom event that the form can listen to
    const event = new CustomEvent("trix:autosave", {
      detail: { content: this.trixEditor.value },
      bubbles: true
    })
    this.trixEditor.dispatchEvent(event)

    this.modified = false
    this.lastSaved = Date.now()

    // Simulate save completion (in real app, listen for server response)
    setTimeout(() => {
      this.updateSaveStatus("Zapisano", "text-green-600")
      setTimeout(() => {
        this.updateSaveStatus("", "")
      }, 2000)
    }, 500)
  }

  updateSaveStatus(message, className) {
    if (!this.hasSaveStatusTarget) return

    this.saveStatusTarget.textContent = message
    this.saveStatusTarget.className = `save-status text-sm ${className}`
  }

  // File upload handling
  setupFileUploadHandler() {
    // Configuration for file uploads
    this.uploadUrl = this.trixEditor.dataset.directUploadUrl || "/rails/active_storage/direct_uploads"
  }

  handleFileAccept(event) {
    const acceptedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp", "image/svg+xml"]
    const maxFileSize = 10 * 1024 * 1024 // 10MB

    const file = event.file

    if (!acceptedTypes.includes(file.type)) {
      event.preventDefault()
      alert("Tylko pliki graficzne są dozwolone (JPEG, PNG, GIF, WebP, SVG)")
      return
    }

    if (file.size > maxFileSize) {
      event.preventDefault()
      alert("Plik jest zbyt duży. Maksymalny rozmiar to 10MB")
      return
    }
  }

  handleAttachmentAdd(event) {
    const attachment = event.attachment

    if (attachment.file) {
      this.uploadAttachment(attachment)
    }
  }

  handleAttachmentRemove(event) {
    // Can be used to clean up server-side files
  }

  uploadAttachment(attachment) {
    const file = attachment.file
    const form = new FormData()
    form.append("file", file)

    // Show upload progress
    this.updateSaveStatus("Przesyłanie pliku...", "text-blue-600")

    // In a real implementation, this would upload to ActiveStorage
    // For now, we'll simulate the upload
    setTimeout(() => {
      attachment.setAttributes({
        url: URL.createObjectURL(file),
        href: URL.createObjectURL(file)
      })
      this.updateSaveStatus("Plik przesłany", "text-green-600")
      setTimeout(() => {
        this.updateSaveStatus("", "")
      }, 2000)
    }, 1000)
  }

  // Keyboard shortcuts
  setupKeyboardShortcuts() {
    this.trixEditor.addEventListener("keydown", (event) => {
      // Ctrl/Cmd + S to save
      if ((event.ctrlKey || event.metaKey) && event.key === 's') {
        event.preventDefault()
        this.autoSave()
      }

      // Ctrl/Cmd + Shift + X to clear formatting
      if ((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === 'X') {
        event.preventDefault()
        this.clearFormatting()
      }
    })
  }

  // Public methods that can be called from outside
  save() {
    this.autoSave()
  }

  getContent() {
    return this.trixEditor.value
  }

  setContent(content) {
    this.trixEditor.value = content
    this.updateCounter()
  }

  clear() {
    if (!this.trixEditor || !this.trixEditor.editor) return
    this.trixEditor.editor.loadHTML("")
    this.updateCounter()
  }
}