#require('rspec')
require "spec_helper"

describe 'Master Text Pages' do

  before { login }
  let(:login) { stubbed_login_as_user }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit master_texts_path
      current_path.should == new_user_session_path
    end
  end

  describe "index" do
    it "can list several" do
      texts = build_stubbed_list(:master_text, 3)
      MasterText.stub(all: texts)
      visit master_texts_path
    end
    context "with plural forms" do
      it "can list one" do
        texts = build_stubbed_list(:master_text, 1, pluralizable: true, one: 'one-one', many: 'many-many-many')
        MasterText.stub(all: texts)
        visit master_texts_path
        page.should have_content('many-many-many')
        page.should have_content('one-one')
      end
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
    let(:master_text) { create(:master_text) }
    before { visit edit_master_text_path(master_text) }
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
    it "can change pluralizable" do
      LocalizedTextEnforcer.any_instance.should_receive(:master_text_changed).with(master_text)
      page.should have_css("form.master_text")
      expect {
        page.check('plural')
        click_on "Save"
      }.to change { master_text.reload.pluralizable }
      page.should_not have_css("form.master_text")

    end

    context "when pluralizable" do
      let(:master_text) { create(:master_text, pluralizable: true) }
      it "allows me to change one and many" do
        fill_in "master_text_one", with: "My one one"
        fill_in "master_text_many", with: "My many many"
        expect {
          click_on "Save"
        }.to change { [master_text.reload.one, master_text.many] }
        page.should_not have_css("form.master_text")
      end
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