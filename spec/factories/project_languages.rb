# frozen_string_literal: true

FactoryBot.define do
  factory :project_language do
    language { create(:language) }
    project { create(:project) }
  end
end
