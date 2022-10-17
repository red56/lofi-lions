require "rails_helper"

describe "Localized View pages", type: :feature do

  before { login }
  let(:login) { stubbed_login_as_developer }
  let!(:project) { create :project }
  let(:project_language) { create :project_language, language: create(:language), project: project }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit project_language_views_path(project_language)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  context "when logged in as non-developer" do
    let(:login) { stubbed_login_as_user }
    let(:language) { project_language.language }
    let(:master_text_in_view) { master_texts.last }
    before {
      language
      view.key_placements.create!(master_text: master_text_in_view)
      view.reload
      master_text_in_view.reload
      language.reload
    }
    let(:view) { create :view, project: project }
    let(:master_texts) { create_list(:master_text, 3, project: project).tap do |mts|
      mts.each { |mt| create(:localized_text, master_text: mt, project_language: project_language) }
    end
    }

    it "project language show links to localized views" do
      visit project_language_path(project_language)
      expect(page).to have_link_to(project_language_views_path(project_language))
    end
    it "project language texts links to localize views" do
      visit project_language_texts_path(project_language)
      expect(page).to have_link_to(project_language_views_path(project_language))
    end
    it "can list localized views" do
      visit project_language_views_path(project_language)
      expect(page).to have_link_to(project_language_view_path(project_language, view))
    end
    it "can look at localized view" do
      visit project_language_view_path(project_language, view)
      expect(page).to have_content(master_text_in_view.key)
    end

  end
end
