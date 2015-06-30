FactoryGirl.define do
  factory :localized_text do
    master_text { create(:master_text) }
    language { create(:language) }

    factory :stubbed_localized_text do
      master_text { build_stubbed(:master_text) }
      language { build_stubbed(:language) }
    end

  end

end