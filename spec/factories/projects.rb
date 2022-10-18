# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.words(number: 4).join(" ") }
    slug { Project.slugify(name) }
  end
end
