# frozen_string_literal: true

require "rails_helper"

describe ProjectLanguagesController, type: :controller do
  before { login }

  let(:login) { stubbed_login_as_user }
  let(:project_language) { create(:project_language, need_entry_count: nil) }
  let!(:localized_text) { create(:localized_text, project_language: project_language) }

  describe "update" do
    it "calls ProjectLanguage#recalculate_counts!" do
      expect(ProjectLanguage).to receive(:find).and_return(project_language)
      expect(project_language).to receive(:recalculate_counts!)
      put :update, params: { id: project_language.id, project_language: { localized_texts_attributes: [{ id: localized_text.id, text: "flong" }] } }
    end
  end
end
