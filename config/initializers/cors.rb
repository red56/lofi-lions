# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "/assets/*", headers: :any, methods: %i[get options]
  end
end
