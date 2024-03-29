# frozen_string_literal: true

FactoryBot.define do
  factory :localization do
    skip_create

    initialize_with do
      new(attributes[:key], attributes[:value])
    end

    key { Faker::Lorem.words(number: 3).join(".") }
    value { Faker::Lorem.words(number: 10).join(" ") }
  end
end
