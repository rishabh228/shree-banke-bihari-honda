import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.closeOnResize = this.closeOnResize.bind(this)
    this.onKey = this.onKey.bind(this)
    window.addEventListener("resize", this.closeOnResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.closeOnResize)
    document.removeEventListener("keydown", this.onKey)
    document.body.classList.remove("overflow-hidden")
  }

  toggle(event) {
    event?.preventDefault()
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full")
    this.sidebarTarget.classList.add("translate-x-0")
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this.onKey)
    this.element.querySelector("[data-action*='admin-sidebar#toggle']")?.setAttribute("aria-expanded", "true")
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.sidebarTarget.classList.remove("translate-x-0")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.onKey)
    this.element.querySelector("[data-action*='admin-sidebar#toggle']")?.setAttribute("aria-expanded", "false")
  }

  isOpen() {
    return !this.sidebarTarget.classList.contains("-translate-x-full")
  }

  closeOnResize() {
    if (window.innerWidth >= 1024) {
      this.close()
    }
  }

  onKey(event) {
    if (event.key === "Escape") this.close()
  }
}
