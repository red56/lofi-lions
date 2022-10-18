# frozen_string_literal: true

if ENV["GOOGLE_TRANSLATE_API_KEY"]
  puts "setting GOOGLE_TRANSLATE_API_KEY"
  EasyTranslate.api_key = ENV["GOOGLE_TRANSLATE_API_KEY"]
else
  puts "Warning: GOOGLE_TRANSLATE_API_KEY is not set in env"
end
