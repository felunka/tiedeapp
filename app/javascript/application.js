// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "@popperjs/core"
import * as bootstrap from "bootstrap"
import BootstrapTooltips from './components/bootstrap_tooltips'
import '@fortawesome/fontawesome-free'

// https://fontawesome.com/v5.15/how-to-use/on-the-web/using-with/turbolinks
FontAwesome.config.mutateApproach = 'sync'

// Fix popperjs
window.process = {};
window.process.env = {};
window.process.env.NODE_ENV = "production";

BootstrapTooltips.setup();
