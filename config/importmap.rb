# Pin npm packages by running ./bin/importmap

pin "application"
pin "turbo_flash", to: "turbo_flash.js"
pin "flash_messages", to: "flash_messages.js"
pin "flash_auto_refresh", to: "flash_auto_refresh.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "chartkick", to: "https://cdn.jsdelivr.net/npm/chartkick@5.2.1/dist/chartkick.js"
pin "Chart.bundle", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"
