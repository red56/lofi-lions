FactoryGirl.define do
  factory :view do
    name { Faker::Lorem.words(10).join(' ')}
  end
end