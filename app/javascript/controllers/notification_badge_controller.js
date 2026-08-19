import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 60000 }
  }
  static targets = [ "count" ]

  connect() {
    this.refresh = this.refresh.bind(this)
    this.subscription = consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => this.render(Number(data.count) || 0)
    })
    document.addEventListener("visibilitychange", this.refresh)
    if (this.intervalValue > 0) {
      this.timer = window.setInterval(this.refresh, this.intervalValue)
    }
  }

  disconnect() {
    this.subscription?.unsubscribe()
    window.clearInterval(this.timer)
    document.removeEventListener("visibilitychange", this.refresh)
  }

  async refresh() {
    if (document.hidden) return

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })
      if (!response.ok) return

      const data = await response.json()
      this.render(Number(data.count) || 0)
    } catch (_error) {
      // Keep the last known count if the poll fails.
    }
  }

  render(count) {
    if (!this.hasCountTarget) return

    if (count <= 0) {
      this.countTarget.classList.add("hidden")
      this.countTarget.textContent = ""
      return
    }

    this.countTarget.classList.remove("hidden")
    this.countTarget.textContent = count > 9 ? "9+" : String(count)
  }
}
