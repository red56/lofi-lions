FactoryGirl.define do
  factory :user do
    email { Faker::Internet::email }
    encrypted_password 'something'
  end
end