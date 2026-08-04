// Auto-dismiss flash toasts (no Stimulus required).
const FLASH_DISMISS_MS = 2000

export function dismissFlashToast(toast) {
  if (!toast || toast.dataset.dismissing === "true") return

  toast.dataset.dismissing = "true"
  toast.style.transition = "opacity 300ms ease, transform 300ms ease"
  toast.style.opacity = "0"
  toast.style.transform = "translateY(-0.5rem)"

  window.setTimeout(() => toast.remove(), 300)
}

export function scheduleFlashDismissals() {
  document.querySelectorAll("[data-flash-toast]").forEach((toast) => {
    if (toast.dataset.dismissScheduled === "true") return

    toast.dataset.dismissScheduled = "true"
    window.setTimeout(() => dismissFlashToast(toast), FLASH_DISMISS_MS)
  })
}

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-flash-dismiss]")
  if (!button) return

  dismissFlashToast(button.closest("[data-flash-toast]"))
})

;["DOMContentLoaded", "turbo:load", "turbo:render"].forEach((eventName) => {
  document.addEventListener(eventName, scheduleFlashDismissals)
})

scheduleFlashDismissals()
