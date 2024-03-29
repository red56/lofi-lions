# frozen_string_literal: true

require "rails_helper"

describe "Language Pages", type: :feature do
  let(:language) { create(:language) }
  let(:login) { stubbed_login_as_user }

  before { login }

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
  end

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:language, 3)
      expect(Language).to receive_messages(all: langs) # rubocop:disable RSpec/StubbedMock
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
  end

  describe "new" do
    it "works" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:language_created)
      visit new_language_path
      expect(page).to have_css("form.language")
      fill_in "language_code", with: "FR"
      fill_in "language_name", with: "Frenchie"
      click_on "Save"
      expect(page).not_to have_css("form.language")
    end

    it "displays errors" do
      visit new_language_path
      expect(page).to have_css("form.language")
      fill_in "language_name", with: "fr"
      click_on "Save"
      expect(page).to have_css("form.language")
      expect(page).to have_css("form.language .errors")
    end
  end

  describe "edit" do
    before { visit edit_language_path(language) }

    it "works" do
      expect(page).to have_css("form.language")
      fill_in "language_name", with: "Franglais"
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
      fill_in "language_name", with: ""
      click_on "Save"
      expect(page).to have_css("form.language")
      expect(page).to have_css("form.language .errors")
    end
  end
end
