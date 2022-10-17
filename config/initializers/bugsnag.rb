if ENV["BUGSNAG_API_KEY"].present?
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]
    config.notify_release_stages = ["production", "staging"]
    config.app_version = VERSION
  end
end


