require 'rails_helper'

describe 'Localized Text One by One Edit Page', :type => :feature do
  let!(:project) { create(:project) }
  let!(:project_language) { create(:project_language, project: project) }
  let!(:empty_localized_text) { create(:localized_text, project_language: project_language,
      master_text_id: master_text.id, needs_entry: true) }
  let!(:needs_review_localized_text) { create(:localized_text, project_language: project_language,
      other: "something new", master_text_id: master_text.id, needs_review: true) }
  let!(:master_text) { create(:master_text, key: "I am a master text", project: project) }
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
      visit edit_localized_text_path(empty_localized_text.id)
      fill_in "localized_text[other]", with: "Je suis un master text"
      click_on "Save"
      expect(empty_localized_text.reload.needs_entry).to eq false
    end

    it "saves the comment" do
      visit edit_localized_text_path(empty_localized_text.id)
      fill_in "localized_text_comment", with: "I am a localized comment"
      click_on "Save"
      expect(empty_localized_text.reload.comment).to eq "I am a localized comment"
    end

    it "redirects back to the correct list" do
      visit review_project_language_texts_path(project_language)
      click_link "Edit"
      fill_in "localized_text[other]", with: "Je suis un master text"
      click_on "Save"
      expect(current_path).to eq(review_project_language_texts_path(project_language))
    end

    context "when a localized text has a comment" do
      let(:localized_text) {create(:localized_text, comment: "I am a comment, and a localized one at that")}

      it "displays it" do
        visit edit_localized_text_path(localized_text)
        expect(page).to have_content(localized_text.comment)
      end
    end

    context "with translated_from and needs review" do
      let(:localized_text) {create(:localized_text, translated_from: "I'm the original yo", needs_review: true)}


      it "shows the original" do
        visit edit_localized_text_path(localized_text)
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

    context "when doesn't need review" do
    let(:localized_text) {create(:localized_text, translated_from: "I'm the original yo", needs_review: false)}

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

  describe "workflow from project language page" do
    let(:first_localized_text) {create :localized_text, project_language: project_language}
    let(:another_localized_text){create :localized_text, project_language: project_language}

    it "project_lanaguage # next links through to edit page from overview by calling next_localized_text" do
      expect(ProjectLanguage).to receive(:find).at_least(:once).and_return(project_language)
      expect(project_language).to receive(:next_localized_text).with(nil, all: false).and_return(first_localized_text)
      visit project_language_path(project_language)
      click_on "Start"
      expect(page).to have_current_path(flowedit_localized_text_path(first_localized_text, flow: "needing"))
    end

    it "redirects to the next master text on save" do
      expect(LocalizedText).to receive(:find).at_least(:once).and_return(first_localized_text)
      allow(first_localized_text).to receive(:project_language).and_return(project_language)
      expect(project_language).to receive(:next_localized_text).
              with(first_localized_text.key, all: false).and_return(another_localized_text)
      visit flowedit_localized_text_path(first_localized_text, flow: "needing")
      fill_in "localized_text[other]", with: "Je suis un master text"
      expect{click_on "Save"}.to change{first_localized_text.reload.other}
      expect(page).to have_current_path(flowedit_localized_text_path(another_localized_text.id, flow: "needing"))
    end

    it "redirects to the next master text on skip" do
      expect(ProjectLanguage).to receive(:find).and_return(project_language)
      expect(project_language).to receive(:next_localized_text).with(first_localized_text.key, all: false).
              and_return(another_localized_text)
      visit flowedit_localized_text_path(first_localized_text, flow: "needing")
      click_on "Skip"
      expect(page).to have_current_path(flowedit_localized_text_path(another_localized_text.id, flow: "needing"))
    end

  end

  describe "workflow when all reviewed" do
    let!(:project_language) { create(:project_language, project: project, need_entry_count: 0, need_review_count: 0) }
    let!(:empty_localized_text) { create(:finished_localized_text, project_language: project_language,
      master_text_id: master_text.id, needs_entry: true) }
    let!(:needs_review_localized_text) { nil }
    let!(:alpha_localized) {create :finished_localized_text, project_language: project_language, master_text: alpha}
    let!(:ziggurat_localized){create :finished_localized_text, project_language: project_language, master_text: ziggurat}
    let(:alpha) { create(:master_text, key: "alpha", project: project)}
    let(:ziggurat) { create(:master_text, key: "ziggurat", project: project)}
    it "project_lanaguage # next links through to edit page from overview by calling next_localized_text" do
      visit project_language_path(project_language)
      click_on "Review all"
      expect(page).to have_current_path(flowedit_localized_text_path(alpha_localized, flow: "all"))
    end

    it "redirects to the next master text on save" do
      visit flowedit_localized_text_path(alpha_localized, flow: "all")
      fill_in "localized_text[other]", with: "Je suis un master text"
      expect{click_on "Save"}.to change{alpha_localized.reload.other}
      expect(page).to have_current_path(flowedit_localized_text_path(ziggurat_localized.id, flow: "all"))
    end

    it "redirects to the next master text on next" do
      visit flowedit_localized_text_path(alpha_localized, flow: "all")
      click_on "Next"
      expect(page).to have_current_path(flowedit_localized_text_path(ziggurat_localized.id, flow: "all"))
    end

    it "redirects to the first master text on the last one" do
      visit flowedit_localized_text_path(ziggurat_localized, flow: "all")
      click_on "Next"
      expect(page).to have_current_path(flowedit_localized_text_path(alpha_localized.id, flow: "all"))
      expect(page).to have_content(/last text.*beginning/i)
    end
  end
end
