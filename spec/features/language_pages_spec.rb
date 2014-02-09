#require('rspec')
require "spec_helper"

describe 'Language Pages' do

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:language, 3)
      Language.stub(all: langs)
      visit languages_path
    end
    it "links to new" do
      visit languages_path
      page.should have_link_to(new_language_path)
    end
    it "is linked from home" do
      visit root_path
      page.should have_link_to(languages_path)
    end
  end

  describe "new" do
    it "displays" do
      visit new_language_path
    end
    it "works" do
      LocalizedTextEnforcer.any_instance.should_receive(:language_created)
      visit new_language_path
      page.should have_css("form.language")
      fill_in "language_code", with: 'FR'
      fill_in "language_name", with: 'Frenchie'
      click_on "Save"
      page.should_not have_css("form.language")
    end
    it "displays errors" do
      visit new_language_path
      page.should have_css("form.language")
      fill_in "language_name", with: 'fr'
      click_on "Save"
      page.should have_css("form.language")
      page.should have_css("form.language .errors")
    end
  end
  describe "edit" do
    let(:language){create(:language)}
    before{ visit edit_language_path(language)}
    it "displays" do
      visit new_language_path
    end
    it "works" do
      page.should have_css("form.language")
      fill_in "language_name", with: 'Franglais'
      click_on "Save"
      page.should_not have_css("form.language")
    end
    it "displays errors" do
      page.should have_css("form.language")
      fill_in "language_name", with: ''
      click_on "Save"
      page.should have_css("form.language")
      page.should have_css("form.language .errors")
    end
  end
end