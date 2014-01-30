FactoryGirl.define do
  factory :master_text do
    key { Faker::Lorem.words(4).join('.') }
    text { Faker::Lorem.sentence(8) }
  end
end