FactoryGirl.define do
  factory :language do
    name { Faker::Lorem.words(4).join(' ') }
    code { Faker::Lorem.words(2).collect{|w| w[0..1]}.join('-') }
  end
end