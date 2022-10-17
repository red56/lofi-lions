FactoryBot.define do
  factory :project do
    name { Faker::Lorem.words(4).join(" ") }
    slug { Project.slugify(name) }
  end
end
