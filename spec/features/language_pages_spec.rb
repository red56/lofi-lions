require 'rails_helper'

describe 'Language Pages', :type => :feature do
  let(:language) { create(:language) }

  before { login }
  let(:login) { stubbed_login_as_user }

  context "when not logged in" do
    let(:login) { nil }

    it "languages index redirects to login page" do
      visit languages_path
      expect(current_path).to eq(new_user_session_path)
    end
    it "language page redirects to login page" do
      visit language_path(language)
      expect(current_path).to eq(new_user_session_path)
    end
    it "review localized text page redirects to login page" do
      visit review_language_texts_path(language)
      expect(current_path).to eq(new_user_session_path)
    end
    it "all localized text page redirects to login page" do
      visit language_texts_path(language)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:language, 3)
      allow(Language).to receive_messages(all: langs)
      visit languages_path
    end
    it "links to new" do
      visit languages_path
      expect(page).to have_link_to(new_language_path)
    end
    it "is linked from home" do
      visit root_path
      expect(page).to have_link_to(languages_path)
    end
    context "when logged in as administrator" do
      let(:login) { stubbed_login_as_admin_user }
      it "shows editors" do
        langs = build_stubbed_list(:language, 3)
        user = build_stubbed(:user)
        allow(Language).to receive_messages(all: langs)
        allow(langs).to receive_messages(includes: langs)
        allow(langs.last).to receive_messages(users: [user])
        visit languages_path
        expect(page).to have_content(user.email)
      end
    end
  end

  describe "new" do
    it "displays" do
      visit new_language_path
    end
    it "works" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:project_language_created)
      visit new_language_path
      expect(page).to have_css("form.language")
      fill_in "language_code", with: 'FR'
      fill_in "language_name", with: 'Frenchie'
      click_on "Save"
      expect(page).not_to have_css("form.language")
    end
    it "displays errors" do
      visit new_language_path
      expect(page).to have_css("form.language")
      fill_in "language_name", with: 'fr'
      click_on "Save"
      expect(page).to have_css("form.language")
      expect(page).to have_css("form.language .errors")
    end
  end
  describe "edit" do
    before { visit edit_language_path(language) }
    it "displays" do
      visit new_language_path
    end
    it "works" do
      expect(page).to have_css("form.language")
      fill_in "language_name", with: 'Franglais'
      click_on "Save"
      expect(page).not_to have_css("form.language")
    end
    it "has labels" do
      %w{zero one two few many other}.each do |plural_form|
        expect(page).to have_field("language_pluralizable_label_#{plural_form}")
      end
    end

    it "displays errors" do
      expect(page).to have_css("form.language")
      fill_in "language_name", with: ''
      click_on "Save"
      expect(page).to have_css("form.language")
      expect(page).to have_css("form.language .errors")
    end
  end


end
