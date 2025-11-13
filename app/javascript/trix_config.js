// Trix Editor Configuration and Enhancements
import { icons } from 'lucide'

// Helper function to create icon SVG string from Lucide
function createIconSVG(iconName) {
  const icon = icons[iconName]
  if (!icon) {
    console.error(`Icon ${iconName} not found in lucide`)
    return ''
  }

  // Create SVG element with proper attributes
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">${icon}</svg>`
  return svg
}

// Extend Trix configuration
document.addEventListener('trix-initialize', function() {
  // Custom Trix configuration

  // Set maximum file size (10MB)
  Trix.config.attachments.maxFileSize = 10485760 // 10MB in bytes

  // Set preview size for images
  Trix.config.attachments.preview = {
    presentation: "gallery",
    caption: {
      name: true,
      size: true
    }
  }
})

// Handle file upload events
document.addEventListener('trix-file-accept', function(event) {
  const acceptedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
  const maxFileSize = 10 * 1024 * 1024 // 10MB

  const file = event.file

  if (!acceptedTypes.includes(file.type)) {
    event.preventDefault()
    alert('Tylko pliki graficzne są dozwolone (JPEG, PNG, GIF, WebP, SVG)')
    return
  }

  if (file.size > maxFileSize) {
    event.preventDefault()
    alert('Plik jest zbyt duży. Maksymalny rozmiar to 10MB')
    return
  }
})

// Handle attachment uploads with ActiveStorage Direct Upload
document.addEventListener('trix-attachment-add', function(event) {
  const attachment = event.attachment

  if (attachment.file) {
    uploadFileAttachment(attachment)
  }
})

function uploadFileAttachment(attachment) {
  uploadFile(attachment.file, setProgress, setAttributes)

  function setProgress(progress) {
    attachment.setUploadProgress(progress)
  }

  function setAttributes(attributes) {
    attachment.setAttributes(attributes)
  }
}

function uploadFile(file, progressCallback, successCallback) {
  const key = createStorageKey(file)
  const formData = createFormData(key, file)
  const xhr = new XMLHttpRequest()

  xhr.open('POST', '/rails/active_storage/direct_uploads', true)

  xhr.upload.addEventListener('progress', function(event) {
    const progress = event.loaded / event.total * 100
    progressCallback(progress)
  })

  xhr.addEventListener('load', function(event) {
    if (xhr.status === 200) {
      const response = JSON.parse(xhr.responseText)
      const attributes = {
        url: response.direct_upload.url,
        href: `/rails/active_storage/blobs/${response.signed_id}/${file.name}`
      }
      successCallback(attributes)
    }
  })

  xhr.addEventListener('error', function(event) {
    console.error('Upload failed:', event)
  })

  xhr.send(formData)
}

function createStorageKey(file) {
  const date = new Date()
  const day = date.toISOString().slice(0, 10)
  const name = date.getTime() + '-' + file.name
  return ['uploads', day, name].join('/')
}

function createFormData(key, file) {
  const data = new FormData()
  data.append('blob[key]', key)
  data.append('blob[filename]', file.name)
  data.append('blob[content_type]', file.type)
  data.append('blob[byte_size]', file.size)

  // Get CSRF token from meta tag
  const csrfToken = document.querySelector('meta[name="csrf-token"]')
  if (csrfToken) {
    data.append('authenticity_token', csrfToken.content)
  }

  return data
}

// Add custom toolbar buttons
document.addEventListener('trix-before-initialize', function() {
  // Remove attachment button (we'll handle uploads differently)
  const { lang } = Trix.config

  // Customize toolbar with Lucide icons
  Trix.config.toolbar = {
    getDefaultHTML: function() {
      return `
        <div class="trix-button-row">
          <span class="trix-button-group trix-button-group--text-tools" data-trix-button-group="text-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-bold" data-trix-attribute="bold" data-trix-key="b" title="${lang.bold}" tabindex="-1">${createIconSVG('bold')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-italic" data-trix-attribute="italic" data-trix-key="i" title="${lang.italic}" tabindex="-1">${createIconSVG('italic')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-strike" data-trix-attribute="strike" title="${lang.strike}" tabindex="-1">${createIconSVG('strikethrough')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-link" data-trix-attribute="href" data-trix-action="link" data-trix-key="k" title="${lang.link}" tabindex="-1">${createIconSVG('link')}</button>
          </span>

          <span class="trix-button-group trix-button-group--block-tools" data-trix-button-group="block-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-attribute="heading1" title="${lang.heading1}" tabindex="-1">${createIconSVG('heading1')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-quote" data-trix-attribute="quote" title="${lang.quote}" tabindex="-1">${createIconSVG('quote')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-code" data-trix-attribute="code" title="${lang.code}" tabindex="-1">${createIconSVG('code')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-bullet-list" data-trix-attribute="bullet" title="${lang.bullets}" tabindex="-1">${createIconSVG('list')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-number-list" data-trix-attribute="number" title="${lang.numbers}" tabindex="-1">${createIconSVG('list-ordered')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level" data-trix-action="decreaseNestingLevel" title="${lang.outdent}" tabindex="-1">${createIconSVG('indent-decrease')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-increase-nesting-level" data-trix-action="increaseNestingLevel" title="${lang.indent}" tabindex="-1">${createIconSVG('indent-increase')}</button>
          </span>

          <span class="trix-button-group trix-button-group--file-tools" data-trix-button-group="file-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-attach" data-trix-action="attachFiles" title="${lang.attachFiles}" tabindex="-1">${createIconSVG('paperclip')}</button>
          </span>

          <span class="trix-button-group trix-button-group--history-tools" data-trix-button-group="history-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-undo" data-trix-action="undo" data-trix-key="z" title="${lang.undo}" tabindex="-1">${createIconSVG('undo')}</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-redo" data-trix-action="redo" data-trix-key="shift+z" title="${lang.redo}" tabindex="-1">${createIconSVG('redo')}</button>
          </span>
        </div>

        <div class="trix-dialogs" data-trix-dialogs>
          <div class="trix-dialog trix-dialog--link" data-trix-dialog="href" data-trix-dialog-attribute="href">
            <div class="trix-dialog__link-fields">
              <input type="url" name="href" class="trix-input trix-input--dialog" placeholder="${lang.urlPlaceholder}" aria-label="${lang.url}" required data-trix-input>
              <div class="trix-button-group">
                <input type="button" class="trix-button trix-button--dialog" value="${lang.link}" data-trix-method="setAttribute">
                <input type="button" class="trix-button trix-button--dialog" value="${lang.unlink}" data-trix-method="removeAttribute">
              </div>
            </div>
          </div>
        </div>
      `
    }
  }
})

export default {}