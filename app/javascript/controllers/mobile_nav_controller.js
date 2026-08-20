import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle", "openIcon", "closeIcon"]

  connect() {
    this.onKey = this.onKey.bind(this)
    this.setOpen(false)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
    document.body.classList.remove("overflow-hidden")
  }

  toggle(event) {
    event?.preventDefault()
    this.setOpen(!this.isOpen())
  }

  close() {
    this.setOpen(false)
  }

  isOpen() {
    return this.hasMenuTarget && !this.menuTarget.classList.contains("hidden")
  }

  setOpen(open) {
    if (!this.hasMenuTarget) return

    this.menuTarget.classList.toggle("hidden", !open)
    if (this.hasOpenIconTarget) this.openIconTarget.classList.toggle("hidden", open)
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.toggle("hidden", !open)
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", open ? "true" : "false")
      this.toggleTarget.setAttribute("aria-label", open ? "Close menu" : "Open menu")
    }
    document.body.classList.toggle("overflow-hidden", open)

    if (open) {
      document.addEventListener("keydown", this.onKey)
    } else {
      document.removeEventListener("keydown", this.onKey)
    }
  }

  onKey(event) {
    if (event.key === "Escape") this.close()
  }
}
