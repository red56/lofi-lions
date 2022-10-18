# frozen_string_literal: true

json.array!(@master_texts) do |master_text|
  json.extract! master_text, :key, :text, :comment
  json.url master_text_url(master_text, format: :json)
end
