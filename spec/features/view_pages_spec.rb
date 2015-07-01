require 'rails_helper'

describe 'View pages', :type => :feature do

  before { login }
  let(:login) { stubbed_login_as_developer }

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

  specify "index is linked from homepage" do
    visit "/"
    expect(page).to have_link_to(views_path)
  end

  specify "when creating can write in keys to use" do
    master_texts = create_list(:master_text, 5)
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
    let(:language) { create :language }
    let(:master_text_in_view){master_texts.last}
    before {
      language
      view.key_placements << KeyPlacement.create!(master_text:master_text_in_view)
      view.reload
      master_text_in_view.reload
      language.reload
    }
    let(:view) { create :view }
    let(:master_texts) {
      create_list(:localized_text,3, language: language).collect{|l|l.master_text}}
    it "language index links to localize views" do
      visit languages_path
      expect(page).to have_link_to(language_views_path(language))
    end
    it "language texts links to localize views" do
      visit language_texts_path(language)
      expect(page).to have_link_to(language_views_path(language))
    end
    it "can list localized views" do
      visit language_views_path(language)
      expect(page).to have_link_to(language_view_path(language, view))
    end
    it "can look at localized view" do
      visit language_view_path(language, view)
      expect(page).to have_content(master_text_in_view.key)
    end
  end
end