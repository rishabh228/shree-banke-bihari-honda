import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dismissAfter: { type: Number, default: 6000 } }

  connect() {
    if (this.dismissAfterValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    if (this.timeout) clearTimeout(this.timeout)
    this.element.classList.add("opacity-0", "-translate-y-2", "pointer-events-none")
    window.setTimeout(() => this.element.remove(), 300)
  }
}
