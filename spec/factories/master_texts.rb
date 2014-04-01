FactoryGirl.define do
  factory :master_text do
    key { Faker::Lorem.words(4).join('.') }
    other { Faker::Lorem.sentence(8) }
  end
end