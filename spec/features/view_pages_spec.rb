require 'rails_helper'

describe 'View pages', :type => :feature do

  before { login }
  let(:login) { stubbed_login_as_developer }
  let!(:project) { create :project }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit views_path
      expect(current_path).to eq(new_user_session_path)
    end
  end


  # context "when logged in as non-developer" do
  #   let(:login) { stubbed_login_as_user }
  #   it "is 404" do
  #     begin
  #       visit views_path
  #       expect(page.status_code).to eq(404)
  #     rescue ActionController::RoutingError
  #     end
  #
  #   end
  #
  #   specify "index is not linked from homepage" do
  #     visit "/"
  #     expect(page).not_to have_link_to(views_path)
  #   end
  # end

  specify "when creating can write in keys to use" do
    master_texts = create_list(:master_text, 5, project: project)
    visit new_view_path
    expect(page).to have_css("form.view")
    fill_in :view_name, with: "flongy"
    some_keys = [master_texts[3].key, master_texts[4].key, master_texts[2].key].join("\n")
    fill_in :view_keys, with: some_keys
    click_on "Create View"
    expect(page).not_to have_css("form.view")
    expect(View.last.reload.master_texts.to_a).to eq([master_texts[3], master_texts[4], master_texts[2]])
  end

  context "when logged in as non-developer" do
    let(:login) { stubbed_login_as_user }
    let(:language) { project_language.language }
    let(:project_language) { create :project_language, language: create(:language), project: project }
    let(:master_text_in_view) { master_texts.last }
    before {
      language
      view.key_placements << KeyPlacement.create!(master_text: master_text_in_view)
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

    context "with multiple projects" do
      let!(:projects) { [project]+ [create(:project, name: "Tother One")] }
      let!(:views) { projects.map { |p| p.views.create!(name: "Flong") } }
      it "lists views by project" do
        visit project_language_views_path(project_language)
        views.each do |view|
          expect(page).to have_link_to(project_language_view_path(project_language, view))
        end
        # views.each do |project|
        #   expect(page).to have_link_to(language_project_path(language, project))
        # end
      end
    end
  end
end