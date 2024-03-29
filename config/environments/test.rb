# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Only eager_load on C. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = ENV["CI"].present?

  if false # ENV["CI"] && !ENV["CI_COMPILE_ASSETS"] # not yet compiling on CI # rubocop:disable Lint/LiteralAsCondition
    puts "CI configuration: using compressed and digested assets"
    # Configure public file server for tests with Cache-Control for performance.
    config.public_file_server.enabled = true
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{1.hour.seconds.to_i}"
    }
    config.assets.compress = true
    config.assets.compile = false
    config.assets.digest = true
    config.assets.debug = false
  else
    config.assets.debug = true
  end

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  # config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.active_support.deprecation = :raise
  # config.active_support.deprecation = if ENV["BUNDLE_GEMFILE"]&.ends_with?("Gemfile.next")
  #                                       :stderr
  #                                     else
  #                                       :raise
  #                                     end

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.log_level = :warn

  config.action_controller.action_on_unpermitted_parameters = :stderr

  ENV["DEVISE_KEY"] = "not-so-random"
  config.action_mailer.default_url_options = { host: "www.example.com" }

  # Explicitly express test ordering.
  Rails.application.configure do
    config.active_support.test_order = :sorted # or `:random` if you prefer
  end
end
