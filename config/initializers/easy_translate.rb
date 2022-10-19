# frozen_string_literal: true

if ENV["GOOGLE_TRANSLATE_API_KEY"]
  Rails.logger.info "setting GOOGLE_TRANSLATE_API_KEY"
  EasyTranslate.api_key = ENV["GOOGLE_TRANSLATE_API_KEY"]
else
  Rails.logger.warn "Warning: GOOGLE_TRANSLATE_API_KEY is not set in env"
end
