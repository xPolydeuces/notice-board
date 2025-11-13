// Trix Editor Configuration and Enhancements
import {
  createElement,
  Bold,
  Italic,
  Strikethrough,
  Link,
  Heading1,
  Quote,
  Code,
  List,
  ListOrdered,
  IndentDecrease,
  IndentIncrease,
  Paperclip,
  Undo,
  Redo
} from 'lucide'

// Icon mapping for easy access
const iconMap = {
  'bold': Bold,
  'italic': Italic,
  'strikethrough': Strikethrough,
  'link': Link,
  'heading1': Heading1,
  'quote': Quote,
  'code': Code,
  'list': List,
  'list-ordered': ListOrdered,
  'indent-decrease': IndentDecrease,
  'indent-increase': IndentIncrease,
  'paperclip': Paperclip,
  'undo': Undo,
  'redo': Redo
}

// Helper function to create icon SVG string from Lucide
function createIconSVG(iconName) {
  const IconComponent = iconMap[iconName]
  if (!IconComponent) {
    console.error(`Icon ${iconName} not found in lucide`)
    return iconName // Fallback to text if icon not found
  }

  try {
    // Use Lucide's createElement function to generate the SVG element
    const svgElement = createElement(IconComponent)

    // Set custom attributes after creation
    if (svgElement) {
      svgElement.setAttribute('width', '16')
      svgElement.setAttribute('height', '16')
      svgElement.setAttribute('stroke-width', '2.5')

      // Return the SVG outerHTML as a string
      return svgElement.outerHTML
    }
  } catch (error) {
    console.error(`Error creating icon ${iconName}:`, error)
    return iconName // Fallback to text if icon creation fails
  }

  return iconName // Fallback if svgElement is null
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

// Replace toolbar button text with icons after Trix initializes
document.addEventListener('trix-initialize', function(event) {
  const editor = event.target
  const toolbar = editor.toolbarElement

  if (!toolbar) return

  // Map of button selectors to icon names
  const buttonIconMap = {
    '[data-trix-attribute="bold"]': 'bold',
    '[data-trix-attribute="italic"]': 'italic',
    '[data-trix-attribute="strike"]': 'strikethrough',
    '[data-trix-attribute="href"]': 'link',
    '[data-trix-attribute="heading1"]': 'heading1',
    '[data-trix-attribute="quote"]': 'quote',
    '[data-trix-attribute="code"]': 'code',
    '[data-trix-attribute="bullet"]': 'list',
    '[data-trix-attribute="number"]': 'list-ordered',
    '[data-trix-action="decreaseNestingLevel"]': 'indent-decrease',
    '[data-trix-action="increaseNestingLevel"]': 'indent-increase',
    '[data-trix-action="attachFiles"]': 'paperclip',
    '[data-trix-action="undo"]': 'undo',
    '[data-trix-action="redo"]': 'redo'
  }

  // Replace each button's content with the corresponding icon
  Object.entries(buttonIconMap).forEach(([selector, iconName]) => {
    const button = toolbar.querySelector(selector)
    if (button) {
      const IconComponent = iconMap[iconName]
      if (IconComponent) {
        try {
          // Clear the button text
          button.textContent = ''

          // Create and append the icon
          const iconSVG = createElement(IconComponent)
          iconSVG.setAttribute('width', '16')
          iconSVG.setAttribute('height', '16')
          iconSVG.setAttribute('stroke-width', '2.5')

          button.appendChild(iconSVG)
        } catch (error) {
          console.error(`Error creating icon ${iconName}:`, error)
        }
      }
    }
  })
})

export default {}