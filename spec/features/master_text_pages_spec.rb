#require('rspec')
require "spec_helper"

describe 'Master Text Pages', :type => :feature do

  before { login }
  let(:login) { stubbed_login_as_user }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit master_texts_path
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "index" do
    let(:texts){ build_stubbed_list(:master_text, 3)}
    before{ allow(texts).to receive_messages(order:texts)}
    it "can list several" do
      allow(MasterText).to receive_messages(all: texts)
      visit master_texts_path
    end
    context "with plural forms" do
      let(:texts){ build_stubbed_list(:master_text, 1, pluralizable: true, one: 'one-one', other: 'othery-other') }
      it "can list one" do
        allow(MasterText).to receive_messages(all: texts)
        visit master_texts_path
        expect(page).to have_content('othery-other')
        expect(page).to have_content('one-one')
      end
    end
    it "links to new" do
      visit master_texts_path
      expect(page).to have_link_to(new_master_text_path)
    end
    it "is linked from home" do
      visit root_path
      expect(page).to have_link_to(master_texts_path)
    end
  end

  describe "new" do
    it "displays" do
      visit new_master_text_path
    end
    it "works" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_created)
      visit new_master_text_path
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      fill_in "master_text_text", with: 'My text'
      click_on "Save"
      expect(page).not_to have_css("form.master_text")
    end
    it "displays errors" do
      visit new_master_text_path
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      click_on "Save"
      expect(page).to have_css("form.master_text")
      expect(page).to have_css("form.master_text .errors")
    end
  end
  describe "edit" do
    let(:master_text) { create(:master_text) }
    before { visit edit_master_text_path(master_text) }
    it "displays" do
      visit new_master_text_path
    end
    it "works" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_changed).with(master_text)
      expect(page).to have_css("form.master_text")
      fill_in "master_text_text", with: 'My new text'
      click_on "Save"
      expect(page).not_to have_css("form.master_text")
    end
    it "can change pluralizable" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_changed).with(master_text)
      expect(page).to have_css("form.master_text")
      expect {
        page.check('plural')
        click_on "Save"
      }.to change { master_text.reload.pluralizable }
      expect(page).not_to have_css("form.master_text")

    end

    context "when pluralizable" do
      let(:master_text) { create(:master_text, pluralizable: true) }
      it "allows me to change one" do
        fill_in "master_text_one", with: "My one one"
        expect {
          click_on "Save"
        }.to change { master_text.reload.one }
        expect(page).not_to have_css("form.master_text")
      end
      it "allows me to change many" do
        fill_in "master_text_other", with: "My other other"
        expect {
          click_on "Save"
        }.to change { master_text.reload.other }
        expect(page).not_to have_css("form.master_text")
      end
    end

    it "displays errors" do
      expect_any_instance_of(LocalizedTextEnforcer).not_to receive(:master_text_changed)
      expect(page).to have_css("form.master_text")
      fill_in "master_text_text", with: ''
      click_on "Save"
      expect(page).to have_css("form.master_text")
      expect(page).to have_css("form.master_text .errors")
    end
  end
end