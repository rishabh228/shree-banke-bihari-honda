// Flash must not be saved in Turbo's back/forward cache.
function clearSessionFlash() {
  document.querySelectorAll("[data-flash-toast]").forEach((element) => {
    element.remove()
  })

  document.querySelectorAll("[data-flash-session]").forEach((element) => {
    element.remove()
  })
}

document.addEventListener("turbo:before-cache", clearSessionFlash)
