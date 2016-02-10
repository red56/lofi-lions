require 'rails_helper'

describe 'Project Pages', :type => :feature do
  let!(:project) { create(:project, name: "steve") }
  let!(:project_language) { create(:project_language, language_id: language.id, project_id: project.id) }
  let(:language) { create(:language, name: "French") }

  let(:do_logging_in) { stubbed_login_as_admin_user }
  before { do_logging_in }

  it "shows project name" do
    visit project_path(project)
    expect(page).to have_content(project.name)
  end

  it "links to project languages" do
    visit project_path(project)
    expect(page).to have_content(project_language.language.name)
    expect(page).to have_link_to(project_language_path(project_language))
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

  describe "edit" do
    let!(:other_language) { create(:language, name: "Spanish") }

    it "can edit name" do
      visit edit_project_path(project)
      fill_in "Name", with: "What you like"
      click_on "Save"
      expect(project.reload.name).to eq "What you like"
    end

    it "can edit description" do
      visit edit_project_path(project)
      fill_in "Description", with: "Something you like"
      click_on "Save"
      expect(project.reload.description).to eq "Something you like"
      expect(page).to have_content "Something you like"
    end

    it "can add new project languages" do
      visit edit_project_path(project)
      check("project_language_ids_#{other_language.id}")
      click_on "Save"
      expect(project.reload.languages).to include(other_language)
    end

    context "with non admin user" do
      let(:do_logging_in) { stubbed_login_as_user }

      it "won't work" do
        expect {visit edit_project_path(project)}.to raise_error /Not Found/
      end
    end
  end


end
