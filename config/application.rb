# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LofiLions
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # returns staging if you set
    def pseudo_env
      ENV["PSEUDO_PRODUCTION_ENV"]&.inquiry || Rails.env
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = true

    config.generators do |g|
      g.helper nil
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
      g.fixture_replacement :factory_bot
      g.stylesheets false
    end
  end
end
