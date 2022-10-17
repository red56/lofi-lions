FactoryBot.define do
  factory :user do
    email { Faker::Internet::email }
    encrypted_password 'something'
    password 'userpass'
    password_confirmation 'userpass'
  end
end
