require 'rails_helper'

describe 'Localized Text One by One Edit Page', :type => :feature do
  let!(:project_language) { create(:project_language) }
  let!(:empty_localized_text) { create(:localized_text, project_language: project_language,
      master_text_id: master_text.id, needs_entry: true) }
  let!(:needs_review_localized_text) { create(:localized_text, project_language: project_language,
      other: "something new", master_text_id: master_text.id, needs_review: true) }
  let!(:master_text) { create(:master_text, key: "I am a master text") }
  before { login }
  let(:login) { stubbed_login_as_user }

  describe "getting there" do
    it "links from project language text list" do
      visit entry_project_language_texts_path(project_language)
      expect(page).to have_content("Edit")
      expect(page).to have_link_to(edit_localized_text_path(empty_localized_text.id))
    end
  end

  describe "the page" do
    it "saves updated text" do
      visit edit_localized_text_path(empty_localized_text.id)
      fill_in "localized_text[other]", with: "Je suis un master text"
      click_on "Save"
      expect(empty_localized_text.reload.needs_entry).to eq false
    end

    it "redirects back to the correct list" do
      visit review_project_language_texts_path(project_language)
      click_link "Edit"
      fill_in "localized_text[other]", with: "Je suis un master text"
      click_on "Save"
      expect(current_path).to eq(review_project_language_texts_path(project_language))
    end

    context "with translated_from" do
      let(:localized_text) {create(:localized_text, translated_from: "I'm the original yo")}

      it "shows the original" do
        visit edit_localized_text_path(localized_text)
        page.save_and_open_page
        expect(page).to have_content(localized_text.translated_from)
      end
    end

    context "when translated_from empty" do
      let(:localized_text) {create(:localized_text, translated_from: nil)}

      it "doesn't display the original" do
        visit edit_localized_text_path(localized_text)
        expect(page).to_not have_css(".translated_from")
      end
    end
  end

  describe "review" do
    it "once reviewed texts are moved out of list" do
      visit review_project_language_texts_path(project_language)
      click_link "Edit"
      fill_in "localized_text[other]", with: "Je suis un master text"
      click_on "Save"
      expect(page).to_not have_css("#localized_text_#{needs_review_localized_text.id}")
    end
  end
end