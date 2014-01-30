FactoryGirl.define do
  factory :localized_text do
    master_text { create(:master_text) }
    language { create(:language)}
  end
end