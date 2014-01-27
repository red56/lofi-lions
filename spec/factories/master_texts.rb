FactoryGirl.define do
  factory :master_text do
    key { Faker::Lorem.words(3).join('.') }
  end
end