require 'rails_helper'

describe 'Home page', :type => :feature do

  let!(:project) {create(:project, name: "steve" )}
  let(:project_language) {create(:project_language, language_id: language.id)}
  let(:language) {create(:language, name: "French")}

  context "when not logged in" do
    it "redirects to login page" do
      visit '/'
      expect(current_path).to eq(new_user_session_path)
    end
  end

  context "when logged in as developer" do
    before do
      stubbed_login_as_developer
    end

    it "works" do
      visit '/'
      expect(current_path).to eq('/')
      expect(page).to have_content(@user.email)
    end
    it "has logout" do
      visit '/'
      click_on "Logout"
    end
    it "links to projects" do
      visit '/'
      expect(page).to have_content(project.name)
      expect(page).to have_link_to(project_path(project))
    end
  end

  context "when logged in as admin" do
    before do
      stubbed_login_as_admin_user
    end

    it "links to projects" do
      visit '/'
      expect(page).to have_content(project.name)
      expect(page).to have_link_to(project_path(project))
    end
  end

  context "when logged in as a standard user" do
    before do
      stubbed_login_as_user
      allow(@user).to receive(:project_languages).and_return([project_language])
    end

    it "doesn't link to projects" do
      visit '/'
      expect(page).to_not have_content(project.name)
      expect(page).to_not have_link_to(project_path(project))
    end

    it "links to project languages" do
      visit '/'
      expect(page).to have_content(project_language.language.name)
      expect(page).to have_link_to(project_language_path(project_language))
    end
  end

  describe "workflow edit" do
    context "with none to enter/review" do
      let!(:complete_project_language) { create(:project_language, language_id: language.id, need_entry_count: 0,
          need_review_count: 0) }

      before do
        stubbed_login_as_developer
      end

      it "doesn't display the start button" do
        visit "/"
        expect(page).to_not have_link_to(next_project_language_path(complete_project_language))
      end
    end

    context "with to enter/review" do
      let!(:project_language) { create(:project_language, language_id: language.id, need_entry_count: 1,
          need_review_count:
              3) }

      before do
        stubbed_login_as_developer
      end

      it "doesn't display the start button" do
        visit "/"
        expect(page).to have_link_to(next_project_language_path(project_language))
      end
    end
  end
end
