require 'rails_helper'

describe 'Home page', :type => :feature do

  let!(:project) {create(:project, name: "steve" )}

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
    it "shows projects" do
      visit '/'
      expect(page).to have_content(project.name)
      expect(page).to have_link_to(project_path(project))
    end
  end

  context "when logged in as a standard user" do
    before do
      stubbed_login_as_user
    end

    it "doesn't show projects" do
      visit '/'
      expect(page).to_not have_content(project.name)
      expect(page).to_not have_link_to(project_path(project))
    end
  end
end
