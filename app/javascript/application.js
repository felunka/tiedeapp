// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "@popperjs/core"
import * as bootstrap from "bootstrap"
import BootstrapTooltips from './components/bootstrap_tooltips'

// Fix popperjs
window.process = {};
window.process.env = {};
window.process.env.NODE_ENV = "production";

BootstrapTooltips.setup();
