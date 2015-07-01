FactoryGirl.define do
  factory :project do
    name { Faker::Lorem.words(4).join(' ') }
  end
end