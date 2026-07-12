import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor"]

  connect() {
    this.resizeButtons = []

    this.clickHandler = (event) => {
      const figure = event.target.closest("figure.attachment")
      this.currentFigure = figure && this.editorTarget.contains(figure) ? figure : null
      this.updateResizeButtons()
    }

    this.initHandler = () => this.setupToolbar()
    this.selectionHandler = () => this.updateResizeButtons()
    this.documentClickHandler = (event) => {
      const toolbar = this.editorTarget.toolbarElement
      if (this.element.contains(event.target) || toolbar?.contains(event.target)) return

      this.currentFigure = null
      this.updateResizeButtons()
    }

    this.editorTarget.addEventListener("click", this.clickHandler)
    this.editorTarget.addEventListener("trix-initialize", this.initHandler)
    document.addEventListener("selectionchange", this.selectionHandler)
    document.addEventListener("mousedown", this.documentClickHandler)
    this.setupToolbar()
  }

  disconnect() {
    this.editorTarget.removeEventListener("click", this.clickHandler)
    this.editorTarget.removeEventListener("trix-initialize", this.initHandler)
    document.removeEventListener("selectionchange", this.selectionHandler)
    document.removeEventListener("mousedown", this.documentClickHandler)
  }

  setupToolbar() {
    const toolbarRow = this.editorTarget.toolbarElement?.querySelector(".trix-button-row")
    if (!toolbarRow || toolbarRow.querySelector("[data-trix-editor-resize-group='true']")) return

    const group = document.createElement("span")
    group.className = "trix-button-group"
    group.dataset.trixEditorResizeGroup = "true"

    this.buildButton(group, window.I18n.articles.form.image_size_small, 33)
    this.buildButton(group, window.I18n.articles.form.image_size_medium, 66)
    this.buildButton(group, window.I18n.articles.form.image_size_large, 100)

    toolbarRow.appendChild(group)
    this.updateResizeButtons()
  }

  buildButton(group, label, size) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "trix-button"
    button.textContent = label
    button.disabled = true
    // Trix image selection is lost on click unless default mousedown is prevented.
    button.addEventListener("mousedown", (event) => {
      event.preventDefault()
      this.resize(size)
    })
    this.resizeButtons.push(button)
    group.appendChild(button)
  }

  resize(size) {
    const figure = this.activeFigure()
    const image = figure?.querySelector("img")
    if (!figure || !image) return

    const editor = this.editorTarget.editor
    const documentModel = editor?.getDocument?.()
    const attachment = this.selectedAttachment(figure)
    const presentation = this.presentationForSize(size)

    // Persist in Trix model so resize survives save + reload.
    if (attachment && documentModel?.updateAttributesForAttachment && editor?.loadDocument) {
      const updatedDocument = documentModel.updateAttributesForAttachment({ presentation }, attachment)
      if (updatedDocument) {
        editor.loadDocument(updatedDocument)
      }
    }

    // Patch DOM attributes for immediate visual feedback and older builds.
    this.writeAttachmentAttributes(figure, presentation)
    figure.style.width = ""
    figure.style.maxWidth = ""
    image.style.width = ""
    image.style.height = ""

    // Notify ActionText/Trix that content changed.
    this.editorTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.syncHiddenInput()
    this.updateResizeButtons()
  }

  updateResizeButtons() {
    const enabled = !!this.activeFigure()
    this.resizeButtons.forEach((button) => {
      button.disabled = !enabled
    })
  }

  selectedAttachment(figure) {
    const editor = this.editorTarget.editor
    if (!editor || !figure) return null

    const selectedData = this.readJson(figure.dataset.trixAttachment)
    if (!selectedData) return null

    const attachments = editor.getDocument()?.getAttachments?.() || []
    return attachments.find((attachment) => this.attachmentMatches(attachment, selectedData)) || null
  }

  activeFigure() {
    if (this.currentFigure && this.editorTarget.contains(this.currentFigure)) return this.currentFigure

    const direct = this.editorTarget.querySelector("figure.attachment.attachment--selected") ||
      this.editorTarget.querySelector("figure.attachment.trix-selected") ||
      this.editorTarget.querySelector("figure.attachment--preview.attachment--selected") ||
      this.editorTarget.querySelector("figure.attachment--preview.trix-selected")
    if (direct) return direct

    return null
  }

  attachmentMatches(attachment, selectedData) {
    const attrs = this.attachmentAttributes(attachment)

    if (selectedData.sgid && attrs.sgid) return selectedData.sgid === attrs.sgid
    if (selectedData.url && attrs.url) return selectedData.url === attrs.url
    if (selectedData.href && attrs.href) return selectedData.href === attrs.href

    return selectedData.filename === attrs.filename &&
      selectedData.filesize === attrs.filesize &&
      selectedData.contentType === attrs.contentType
  }

  attachmentAttributes(attachment) {
    if (!attachment) return {}
    return attachment.getAttributes?.() || attachment.attributes || {}
  }

  writeAttachmentAttributes(figure, presentation) {
    const attrs = this.readJson(figure.dataset.trixAttributes) || {}
    attrs.presentation = presentation
    figure.dataset.trixAttributes = JSON.stringify(attrs)
  }

  syncHiddenInput() {
    const inputId = this.editorTarget.getAttribute("input")
    if (!inputId) return

    const hiddenInput = document.getElementById(inputId)
    if (hiddenInput) hiddenInput.value = this.editorTarget.innerHTML
  }

  presentationForSize(size) {
    if (size <= 33) return "small"
    if (size <= 66) return "medium"
    return "large"
  }

  readJson(raw) {
    if (!raw) return null

    try {
      return JSON.parse(raw)
    } catch {
      return null
    }
  }

  t(path, fallback) {
    const keys = path.split(".")
    let value = window.i18n

    for (const key of keys) {
      if (!value || typeof value !== "object") return fallback
      value = value[key]
    }

    return typeof value === "string" ? value : fallback
  }
}
