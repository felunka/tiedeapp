require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tiedeapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.i18n.default_locale = :de

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.x.membership_fee.normal = 60
    config.x.membership_fee.reduced = 30

    config.x.from_email = 'noreply@felunka.de'

    config.after_initialize do
      config.x.git_ref = `git rev-parse --short HEAD`
    end
  end
end
