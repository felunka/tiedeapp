# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo", to: "https://ga.jspm.io/npm:@hotwired/turbo@7.1.0/dist/turbo.es2017-esm.js"
pin "@rails/actioncable/src", to: "https://ga.jspm.io/npm:@rails/actioncable@7.0.2/src/index.js"
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.1.3/dist/js/bootstrap.esm.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.2/lib/index.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js", preload: true
pin "select2", to: "https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"
pin "@nathanvda/cocoon", to: "https://ga.jspm.io/npm:@nathanvda/cocoon@1.2.14/cocoon.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from 'app/javascript/components', under: 'components'
pin_all_from 'app/javascript/tidy_layout', under: 'tidy_layout'
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "js-cookie", to: "https://ga.jspm.io/npm:js-cookie@3.0.1/dist/js.cookie.mjs"
pin "panzoom", to: "https://ga.jspm.io/npm:panzoom@9.4.3/index.js"
pin "amator", to: "https://ga.jspm.io/npm:amator@1.1.0/index.js"
pin "bezier-easing", to: "https://ga.jspm.io/npm:bezier-easing@2.1.0/src/index.js"
pin "ngraph.events", to: "https://ga.jspm.io/npm:ngraph.events@1.2.2/index.js"
pin "wheel", to: "https://ga.jspm.io/npm:wheel@1.0.0/index.js"
