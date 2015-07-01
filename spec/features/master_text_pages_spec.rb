#require('rspec')
require 'rails_helper'

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
    let(:texts) { build_stubbed_list(:master_text, 3) }
    before { allow(texts).to receive_messages(order: texts, includes: texts) }
    it "can list several" do
      allow(MasterText).to receive_messages(all: texts)
      visit master_texts_path
    end
    context "with plural forms" do
      let(:texts) { build_stubbed_list(:master_text, 1, pluralizable: true, one: 'one-one', other: 'othery-other') }
      it "can list one" do
        allow(MasterText).to receive_messages(all: texts)
        visit master_texts_path
        expect(page).to have_content('othery-other')
        expect(page).to have_content('one-one')
      end
    end
    it "links to new" do
      login
      expect(@user).to receive_messages(is_developer?: true)
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
    it "works for developer" do
      expect(@user).to receive_messages(is_developer?: true)
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_created)
      visit new_master_text_path
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      fill_in "master_text_text", with: 'My text'
      click_on "Save"
      expect(page).not_to have_css("form.master_text")
    end
    it "displays errors" do
      expect(@user).to receive_messages(is_developer?: true)
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
    let(:login) { stubbed_login_as_developer }
    before { visit edit_master_text_path(master_text) }
    it "displays" do
      visit new_master_text_path
    end
    context "for editor" do
      let(:login) { stubbed_login_as_user }
      it "works" do
        expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_changed).with(master_text)
        expect(page).to have_css("form.master_text")
        fill_in "master_text_text", with: 'My new text'
        click_on "Save"
        expect(page).not_to have_css("form.master_text")
      end
    end
    it "works for developer to change key" do
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'new.key'
      click_on "Save"
      expect(page).not_to have_css("form.master_text")
    end

    context "with views" do
      let(:view){create(:view)}
      let(:master_text) {
        view
        super()
      }
      it "works for developer to add view" do
        expect(page).to have_css("form.master_text")
        fill_in "master_text_key", with: 'new.key'
        find("#master_text_view_ids_#{view.id}").set(true)
        click_on "Save"
        expect(page).not_to have_css("form.master_text")
        expect(page).to have_content(view.name)
        expect(page).to have_link_to(view_path(view))
      end
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

  describe "show" do
    let(:master_text){build_stubbed :master_text}
    let(:localized_texts){build_stubbed_list :localized_text, 3, master_text: master_text}
    before do
      allow(MasterText).to receive_messages(find: master_text)
      expect(master_text).to receive_messages(localized_texts: localized_texts)
      allow(localized_texts).to receive_messages(includes: localized_texts)
    end
    it "shows multiple languages" do
      visit master_text_path(master_text)
    end
  end

end