#require('rspec')
require "spec_helper"

describe 'Master Text Pages' do

  describe "index" do
    it "can list several" do
      texts = build_stubbed_list(:master_text, 3)
      MasterText.stub(all: texts)
      visit master_texts_path
    end
    it "links to new" do
      visit master_texts_path
      page.should have_link_to(new_master_text_path)
    end
    it "is linked from home" do
      visit root_path
      page.should have_link_to(master_texts_path)
    end
  end

  describe "new" do
    it "displays" do
      visit new_master_text_path
    end
    it "works" do
      LocalizedTextEnforcer.any_instance.should_receive(:master_text_created)
      visit new_master_text_path
      page.should have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      fill_in "master_text_text", with: 'My text'
      click_on "Save"
      page.should_not have_css("form.master_text")
    end
    it "displays errors" do
      visit new_master_text_path
      page.should have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      click_on "Save"
      page.should have_css("form.master_text")
      page.should have_css("form.master_text .errors")
    end
  end
  describe "edit" do
    let(:master_text){create(:master_text)}
    before{ visit edit_master_text_path(master_text)}
    it "displays" do
      visit new_master_text_path
    end
    it "works" do
      LocalizedTextEnforcer.any_instance.should_receive(:master_text_changed).with(master_text)
      page.should have_css("form.master_text")
      fill_in "master_text_text", with: 'My new text'
      click_on "Save"
      page.should_not have_css("form.master_text")
    end
    it "displays errors" do
      LocalizedTextEnforcer.any_instance.should_not_receive(:master_text_changed)
      page.should have_css("form.master_text")
      fill_in "master_text_text", with: ''
      click_on "Save"
      page.should have_css("form.master_text")
      page.should have_css("form.master_text .errors")
    end
  end
end