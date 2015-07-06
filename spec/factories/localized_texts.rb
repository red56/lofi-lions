FactoryGirl.define do
  factory :localized_text do
    master_text { create(:master_text) }
    project_language { create(:project_language, project_id: master_text.project_id)}

    factory :stubbed_localized_text do
      master_text { build_stubbed(:master_text) }
      project_language { build_stubbed(:project_language, project_id: master_text.project_id) }
    end

  end

end