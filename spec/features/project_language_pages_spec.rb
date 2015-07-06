require 'rails_helper'

describe 'Project Language Pages', :type => :feature do
  let(:project_language) { create(:project_language) }

  before { login }
  let(:login) { stubbed_login_as_user }

  context "when not logged in" do
    let(:login) { nil }

    it "project_langages index redirects to login page" do
      visit project_languages_path
      expect(current_path).to eq(new_user_session_path)
    end
    it "project_langage page redirects to login page" do
      visit project_language_path(project_langage)
      expect(current_path).to eq(new_user_session_path)
    end
    it "review localized text page redirects to login page" do
      visit review_language_texts_path(project_langage)
      expect(current_path).to eq(new_user_session_path)
    end
    it "all localized text page redirects to login page" do
      visit project_langage_texts_path(project_langage)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:project_langage, 3)
      allow(Language).to receive_messages(all: langs)
      visit project_langages_path
    end
    it "links to new" do
      visit project_langages_path
      expect(page).to have_link_to(new_language_path)
    end
    it "is linked from home" do
      visit root_path
      expect(page).to have_link_to(project_langages_path)
    end
    context "when logged in as administrator" do
      let(:login) { stubbed_login_as_admin_user }
      it "shows editors" do
        langs = build_stubbed_list(:project_langage, 3)
        user = build_stubbed(:user)
        allow(Language).to receive_messages(all: langs)
        allow(langs).to receive_messages(includes: langs)
        allow(langs.last).to receive_messages(users: [user])
        visit project_langages_path
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
      expect(page).to have_css("form.project_langage")
      fill_in "project_langage_code", with: 'FR'
      fill_in "project_langage_name", with: 'Frenchie'
      click_on "Save"
      expect(page).not_to have_css("form.project_langage")
    end
    it "displays errors" do
      visit new_language_path
      expect(page).to have_css("form.project_langage")
      fill_in "project_langage_name", with: 'fr'
      click_on "Save"
      expect(page).to have_css("form.project_langage")
      expect(page).to have_css("form.project_langage .errors")
    end
  end
  describe "edit" do
    before { visit edit_language_path(project_langage) }
    it "displays" do
      visit new_language_path
    end
    it "works" do
      expect(page).to have_css("form.project_langage")
      fill_in "project_langage_name", with: 'Franglais'
      click_on "Save"
      expect(page).not_to have_css("form.project_langage")
    end
    it "has labels" do
      %w{zero one two few many other}.each do |plural_form|
        expect(page).to have_field("project_langage_pluralizable_label_#{plural_form}")
      end
    end

    it "displays errors" do
      expect(page).to have_css("form.project_langage")
      fill_in "project_langage_name", with: ''
      click_on "Save"
      expect(page).to have_css("form.project_langage")
      expect(page).to have_css("form.project_langage .errors")
    end
  end


  describe "translations" do
    let(:ok_localized_text) { create(:localized_text, project_langage: project_langage, text: "zongy-bo!") }
    let(:empty_localized_text) { create(:localized_text, project_langage: project_langage, needs_entry: true) }
    let(:needs_review_localized_text) { create(:localized_text, project_langage: project_langage,
        other: "something new", needs_review: true) }
    let(:localized_texts) { [ok_localized_text, empty_localized_text, needs_review_localized_text] }

    before { project_langage }

    shared_examples_for "localized text list" do
      it "displays one" do
        localized_text
        visit path
        expect(page).to have_content(localized_text.master_text.text)
        expect(page).to have_css("#localized_text_#{localized_text.id}")
      end
      it "updates one" do
        localized_text
        visit path
        fill_in :project_langage_localized_texts_attributes_0_text, with: "flounce"
        click_on "Save"
        visit project_langage_texts_path(project_langage)
        expect(page).to have_content("flounce")
      end

      context 'when pluralizable' do
        before { allow_any_instance_of(MasterText).to receive_messages(pluralizable: true) }
        it "displays" do
          localized_text
          visit path
          expect(page).to have_content(localized_text.master_text.other)
          expect(page).to have_css("#localized_text_#{localized_text.id}")
        end
        it "updates a localized other" do
          localized_text
          visit path
          fill_in :project_langage_localized_texts_attributes_0_other, with: "flounce"
          click_on "Save"
          visit project_langage_texts_path(project_langage)
          expect(page).to have_content("flounce")
        end
        it "has correct other fields/labels" do
          pending
          flunk "need to test this with different project_langage types"
        end
      end
      it "linked from index" do
        visit project_langages_path
        expect(page).to have_link_to(path)
      end
      it "linked from all" do
        visit project_langage_texts_path(project_langage)
        expect(page).to have_link_to(path)
      end
      it "linked from entry" do
        visit entry_language_texts_path(project_langage)
        expect(page).to have_link_to(path)
      end
      it "linked from review" do
        visit review_language_texts_path(project_langage)
        expect(page).to have_link_to(path)
      end
      it "is active" do
        visit path
        within "ul.localized-texts.nav li.active" do
          expect(page).to have_link_to(path)
        end
      end
    end
    describe "all" do
      let(:localized_text) { ok_localized_text }
      let(:path) { project_langage_texts_path(project_langage) }
      it_behaves_like "localized text list"

      it "displays all" do
        localized_texts
        visit path
        localized_texts.each do |localized_text|
          expect(page).to have_css("#localized_text_#{localized_text.id}")
        end
      end
    end

    describe "translations to enter" do
      let(:localized_text) { empty_localized_text }
      let(:path) { entry_language_texts_path(project_langage) }
      it_behaves_like "localized text list"
      it "should be created needing entry" do
        expect(empty_localized_text.needs_entry).to be_truthy
      end
      it "displays appropriate" do
        localized_texts
        visit path
        expect(page).to have_css("#localized_text_#{empty_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{ok_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{needs_review_localized_text.id}")
      end
    end

    describe "translations to review" do
      let(:localized_text) { needs_review_localized_text }
      let(:path) { review_language_texts_path(project_langage) }
      it_behaves_like "localized text list"
      it "displays all" do
        localized_texts
        visit path
        expect(page).to have_css("#localized_text_#{needs_review_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{ok_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{empty_localized_text.id}")
      end
    end
  end


end
