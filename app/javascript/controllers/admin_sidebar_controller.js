import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.closeOnResize = this.closeOnResize.bind(this)
    window.addEventListener("resize", this.closeOnResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.closeOnResize)
  }

  toggle() {
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full")
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  isOpen() {
    return !this.sidebarTarget.classList.contains("-translate-x-full")
  }

  closeOnResize() {
    if (window.innerWidth >= 1024) {
      this.close()
    }
  }
}
