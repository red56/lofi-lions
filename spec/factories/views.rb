FactoryBot.define do
  factory :view do
    name { Faker::Lorem.words(number: 10).join(" ")}
    project { build_stubbed(:project) }
  end
end
