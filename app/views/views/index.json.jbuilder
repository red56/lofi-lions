# frozen_string_literal: true

json.array!(@views) do |view|
  json.extract! view, :name, :comments
  json.url view_url(view, format: :json)
end
