FactoryGirl.define do
  factory :project_language do
    language { create(:language) }
    project { create(:project) }
    need_entry_count { Random.rand(60) }
    need_review_count { Random.rand(60) }

    factory :stubbed_project_language do
      language { create_stubbed(:language) }
      project { create_stubbed(:project) }
    end
  end
end