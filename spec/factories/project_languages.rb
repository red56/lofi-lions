FactoryGirl.define do
  factory :project_language do
    language { create(:language) }
    project { create(:project) }

    factory :stubbed_project_language do
      language { create_stubbed(:language) }
      project { create_stubbed(:project) }
    end
  end
end