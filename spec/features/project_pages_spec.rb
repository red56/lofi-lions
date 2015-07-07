require 'rails_helper'

describe 'Project Pages', :type => :feature do
  let(:project) { create(:project, name: "steve") }

  before do
    stubbed_login_as_admin_user
  end

  it "shows project name" do
    visit project_path(project)
    expect(page).to have_content(project.name)
  end

  describe "the tabs" do
    it "links to master texts" do
      visit project_path(project)
      expect(page).to have_link_to(project_master_texts_path(project))
    end

    it "links to views" do
      visit project_path(project)
      expect(page).to have_link_to(project_views_path(project))
      end

    it "links to overview" do
      visit project_path(project)
      expect(page).to have_link_to(project_path(project))
    end
  end
end
