FactoryBot.define do
  factory :master_text do
    key { Faker::Lorem.words(4).join('.') }
    other { Faker::Lorem.sentence(8) }
    project { create(:project) }

    after(:stub) do |master_text, e|
      master_text.word_count = master_text.send(:calculate_word_count)
    end
  end
end
