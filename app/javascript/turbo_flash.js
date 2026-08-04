// Flash and one-time banners must not survive Turbo's back/forward cache.
function clearSessionFlash() {
  document.querySelectorAll("#flash-messages [data-controller~='flash']").forEach((element) => {
    element.remove()
  })

  document.querySelectorAll("[data-flash-session]").forEach((element) => {
    element.remove()
  })
}

document.addEventListener("turbo:before-cache", clearSessionFlash)
document.addEventListener("turbo:before-visit", clearSessionFlash)
