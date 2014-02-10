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


  describe "all translations" do
    let(:language){create(:language)}
    let(:master_text){create(:master_text)}
    let(:localized_text){create(:localized_text, master_text: master_text, language: language, text: "zongy-bo!")}
    it "linked from index" do
      language
      visit languages_path
      page.should have_link_to(language_texts_path(language))
    end
    it "displays one" do
      localized_text
      visit language_texts_path(language)
      page.should have_content(master_text.text)
      page.should have_content("zongy-bo!")
    end
    it "updates one" do
      localized_text
      visit language_texts_path(language)
      fill_in :language_localized_texts_attributes_0_text, with: "flounce"
      click_on "Save"
      visit language_texts_path(language)
      page.should have_content("flounce")
    end
  end

end