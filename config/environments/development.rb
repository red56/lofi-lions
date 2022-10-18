Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # guard-livereload needs the rack middeleware:
  config.middleware.insert_after(
    ActionDispatch::Static, Rack::LiveReload,
    port: 35740
  )

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # config.logger = Logger.new(STDOUT) # comment out or we get double logging
  # See everything in the log (default is :info)
  config.log_level = ENV["RAILS_LOG_LEVEL"].presence&.to_sym || :info
  ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = ENV["ACTIVE_RECORD_LOGGING"]&.to_sym || :debug

  config.action_controller.action_on_unpermitted_parameters = :raise

  ENV["DEVISE_KEY"] = "not-so-random"
  config.action_mailer.default_url_options = { host: ENV["CANONICAL_HOST"] || "localhost:3007" }

  # mailcatcher setup
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  # previews
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
end
