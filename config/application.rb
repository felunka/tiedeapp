require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tiedeapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.default_locale = :de

    config.x.membership_fee.normal = 60
    config.x.membership_fee.reduced = 30

    config.x.from_email = 'noreply@tiede.app'

    config.after_initialize do
      if ENV['GITHUB_RELEASE_VERSION'] && ENV['GITHUB_RELEASE_VERSION'] != 'not_set'
        config.x.git_ref = ENV['GITHUB_RELEASE_VERSION']
      else
        config.x.git_ref = `git rev-parse --short HEAD`
      end
    end
  end
end
