require 'rails_helper'

describe 'Project Language Pages', :type => :feature do
  let(:project_language) { create(:project_language) }

  before { login }
  let(:login) { stubbed_login_as_user }

  context "when not logged in" do
    let(:login) { nil }

    it "project_languages index redirects to login page" do
      visit project_languages_path
      expect(current_path).to eq(new_user_session_path)
    end
    it "project_language page redirects to login page" do
      visit project_language_path(project_language)
      expect(current_path).to eq(new_user_session_path)
    end
    it "review localized text page redirects to login page" do
      visit review_project_language_texts_path(project_language)
      expect(current_path).to eq(new_user_session_path)
    end
    it "all localized text page redirects to login page" do
      visit project_language_texts_path(project_language)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:project_language, 3)
      allow(Language).to receive_messages(all: langs)
      visit project_languages_path
    end
  end

  describe "translations" do
    let(:ok_localized_text) { create(:localized_text, project_language: project_language, text: "zongy-bo!") }
    let(:empty_localized_text) { create(:localized_text, project_language: project_language, needs_entry: true) }
    let(:needs_review_localized_text) { create(:localized_text, project_language: project_language,
        other: "something new", needs_review: true) }
    let(:localized_texts) { [ok_localized_text, empty_localized_text, needs_review_localized_text] }

    before { project_language }

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
        fill_in :project_language_localized_texts_attributes_0_text, with: "flounce"
        click_on "Save"
        visit project_language_texts_path(project_language)
        expect(page).to have_content("flounce")
      end
      it "remains on page when information edited and saved" do
        localized_text
        visit path
        fill_in :project_language_localized_texts_attributes_0_text, with: "an edit"
        click_on "Save"
        expect(current_path).to eq(path)
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
          fill_in :project_language_localized_texts_attributes_0_other, with: "flounce"
          click_on "Save"
          visit project_language_texts_path(project_language)
          expect(page).to have_content("flounce")
        end
        it "has correct other fields/labels" do
          pending
          flunk "need to test this with different project_language types"
        end
      end
      it "linked from show" do
        visit project_language_path(project_language)
        expect(page).to have_link_to(path)
      end
      it "linked from all" do
        visit project_language_texts_path(project_language)
        expect(page).to have_link_to(path)
      end
      it "linked from entry" do
        visit entry_project_language_texts_path(project_language)
        expect(page).to have_link_to(path)
      end
      it "linked from review" do
        visit review_project_language_texts_path(project_language)
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
      let(:path) { project_language_texts_path(project_language) }
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
      let(:path) { entry_project_language_texts_path(project_language) }
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
      it "displays number of of items left to enter" do
        localized_texts
        visit path
        expect(page).to have_content("#{project_language.need_entry_count} to enter")
      end
    end

    describe "translations to review" do
      let(:localized_text) { needs_review_localized_text }
      let(:path) { review_project_language_texts_path(project_language) }
      it_behaves_like "localized text list"
      it "displays all" do
        localized_texts
        visit path
        expect(page).to have_css("#localized_text_#{needs_review_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{ok_localized_text.id}")
        expect(page).not_to have_css("#localized_text_#{empty_localized_text.id}")
      end
      it "displays number of of items left to review" do
        localized_texts
        visit path
        expect(page).to have_content("#{project_language.need_review_count} to review")
      end
    end

    context "with none to enter or review" do
      let(:empty_project_language) { create(:project_language, need_entry_count: 0, need_review_count: 0) }

      it "displays 'all entered' with none left to enter" do
        visit entry_project_language_texts_path(empty_project_language)
        expect(page).to have_content("All entered")
      end
      it "displays 'all entered' with none left to enter" do
        visit review_project_language_texts_path(empty_project_language)
        expect(page).to have_content("All reviewed")
      end
    end
  end

  describe "the overview tab" do

    context "with outstanding tasks" do

      let(:project_language) { create(:project_language, need_entry_count: 5, need_review_count: 6) }

      it "has entry count" do
        visit project_language_path(project_language)
        within ".entry" do
          expect(page).to have_content(project_language.need_entry_count)
        end
      end

      it "has review count" do
        visit project_language_path(project_language)
        within ".review" do
          expect(page).to have_content(project_language.need_review_count)
        end
      end
    end

    context "wihout outstanding tasks" do

      let(:project_language) { create(:project_language, need_entry_count: 0, need_review_count: 0) }

      it "has entry count" do
        visit project_language_path(project_language)
        within ".entry" do
          expect(page).to have_content("No outstanding entries")
        end
      end

      it "has review count" do
        visit project_language_path(project_language)
        within ".review" do
          expect(page).to have_content("No outstanding reviews")
        end
      end
    end
  end
end
