import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle", "openIcon", "closeIcon"]

  toggle() {
    const isOpen = !this.menuTarget.classList.contains("hidden")
    this.setOpen(!isOpen)
  }

  setOpen(open) {
    this.menuTarget.classList.toggle("hidden", !open)
    this.openIconTarget.classList.toggle("hidden", open)
    this.closeIconTarget.classList.toggle("hidden", !open)
    this.toggleTarget.setAttribute("aria-expanded", open)
    this.toggleTarget.setAttribute("aria-label", open ? "Close menu" : "Open menu")
  }
}
