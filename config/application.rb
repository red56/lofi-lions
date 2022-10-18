require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LofiLions
  class Application < Rails::Application

    # returns staging if you set
    def pseudo_env
      ENV["PSEUDO_PRODUCTION_ENV"]&.inquiry || Rails.env
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = true

    # TODO: move these to app/lib
    config.autoload_paths += %W(#{config.root}/lib)

    # TODO: rails5.1 Can be removed
    config.action_controller.raise_on_unfiltered_parameters = true

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
