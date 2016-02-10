require 'rails_helper'

describe LocalizedTextsController, type: :controller do

  let!(:project_language) { build_stubbed :project_language, project: project }
  let(:localized_text) {build_stubbed(:localized_text, project_language: project_language, master_text: master_text)}
  let(:master_text) {build_stubbed(:master_text, project: project)}
  let(:project) {build_stubbed(:project)}

  before { login }
  let(:login) { stubbed_login_as_user }

  it "recalculates count on update" do
    allow(localized_text).to receive(:update)
    expect(LocalizedText).to receive(:find).and_return(localized_text)
    expect(project_language).to receive(:recalculate_counts!)
    put :update, {id: localized_text.id, localized_text: {other: "text"}, original_url: "somewhere"}
  end
end
