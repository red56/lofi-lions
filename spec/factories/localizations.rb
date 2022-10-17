FactoryBot.define do
  factory :localization do
    skip_create

    initialize_with do
      new(attributes[:key], attributes[:value])
    end

    key { Faker::Lorem.words(3).join('.')}
    value { Faker::Lorem.words(10).join(' ')}
  end
end
