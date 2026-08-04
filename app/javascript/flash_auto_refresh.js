// Reload public pages after success flash so WhatsApp banner + toast never stick.
function scheduleFlashPageRefresh() {
  const marker = document.getElementById("flash-auto-refresh")
  if (!marker) return

  const url = marker.dataset.flashRefreshUrl || window.location.pathname
  const delay = Number.parseInt(marker.dataset.flashRefreshDelay || "2500", 10)

  window.setTimeout(() => {
    window.location.replace(url)
  }, Number.isNaN(delay) ? 2500 : delay)
}

document.addEventListener("DOMContentLoaded", scheduleFlashPageRefresh)
document.addEventListener("turbo:load", scheduleFlashPageRefresh)
