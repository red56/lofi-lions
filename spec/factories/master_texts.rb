# frozen_string_literal: true

FactoryBot.define do
  factory :master_text do
    key { Faker::Lorem.words(number: 4).join("_") }
    other { Faker::Lorem.sentence(word_count: 8) }
    project { create(:project) }

    after(:stub) do |master_text, e|
      master_text.word_count = master_text.send(:calculate_word_count)
    end
  end
end
