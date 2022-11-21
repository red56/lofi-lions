# frozen_string_literal: true

require "rails_helper"

describe LocalizedTextsController, type: :request do
  let(:login) { stubbed_login_as_user }
  let!(:project_language) { create :project_language, project: project }
  let(:localized_text) { create(:localized_text, project_language: project_language, master_text: master_text) }
  let(:master_text) { create(:master_text, project: project) }
  let(:project) { create(:project) }

  before { login }

  describe "show" do
    it "redirects to master_text" do
      get localized_text_path(localized_text)
      expect(response).to redirect_to(master_text_path(master_text))
    end
  end
end
