require "rails_helper"

describe LocalizedTextsController, type: :controller do
  let!(:project_language) { create :project_language, project: project }
  let(:login) { stubbed_login_as_user }
  let(:localized_text) { create(:localized_text, project_language: project_language, master_text: master_text) }
  let(:master_text) { create(:master_text, project: project) }
  let(:project) { create(:project) }

  before { login }

  it "recalculates count on update" do
    allow(localized_text).to receive(:update)
    expect(LocalizedText).to receive(:find).and_return(localized_text)
    expect(project_language).to receive(:recalculate_counts!)
    put :update, params: { id: localized_text.id, localized_text: { other: "text" }, original_url: "somewhere" }
  end
end
