require 'rails_helper'

describe 'Master Text Pages', :type => :feature do

  before { login }
  let(:login) { stubbed_login_as_user }
  let!(:project) { create :project }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit project_master_texts_path(project)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "index" do
    let(:texts) { build_stubbed_list(:master_text, 3) }

    before do
      allow_to_behave_like_scope(texts)
    end
    it "can list several" do
      allow(project).to receive_messages(master_texts: texts)
      allow(Project).to receive_messages(find: project)
      visit project_master_texts_path(project)
      expect(page).to have_content(texts[0].key)
    end
    context "with plural forms" do
      let(:texts) { build_stubbed_list(:master_text, 1, pluralizable: true, one: 'one-one', other: 'othery-other') }
      it "can list one" do
        allow(project).to receive_messages(master_texts: texts)
        allow(Project).to receive_messages(find: project)
        visit project_master_texts_path(project)
        expect(page).to have_content('othery-other')
        expect(page).to have_content('one-one')
      end
    end
    it "links to new" do
      visit project_master_texts_path(project)
      expect(page).to have_link_to(new_project_master_text_path(project))
    end
  end

  describe "index - unmocked" do
    context "with multiple projects" do
      let!(:other_project) {create(:project)}
      let!(:master_text) {create :master_text, project: project, key: 'my-project-master-text-key'}
      let!(:other_projects_master_text) {create :master_text, project: other_project, key:
              'other-project-master-text-key'}

      it "doesn't show other project's master texts" do
        visit project_master_texts_path(project)
        expect(page).not_to have_content(other_projects_master_text.key)
        visit project_master_texts_path(other_project)
        expect(page).not_to have_content(master_text.key)
      end
    end
  end

  describe "new" do
    it "displays" do
      visit new_project_master_text_path(project)
    end
    def fill_in_and_save
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'my.key'
      fill_in "master_text_text", with: 'My text'
      click_on "Save"
    end
    it "works for developer" do
      expect(@user).to receive_messages(is_developer?: true)
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_created)
      visit new_project_master_text_path(project)
      fill_in_and_save
      expect(page).not_to have_css("form.master_text")
    end
    it "displays errors" do
      expect(@user).to receive_messages(is_developer?: true)
      visit new_project_master_text_path(project)
      fill_in "master_text_key", with: 'my.key'
      click_on "Save"
      expect(page).to have_css("form.master_text")
      expect(page).to have_css("form.master_text .errors")
    end
    context "with a language..." do
      let!(:project_language) {create(:project_language, project: project, need_entry_count: 0)}
      it "updates project language need_entry_count" do
        expect {
          expect(@user).to receive_messages(is_developer?: true)
          visit new_project_master_text_path(project)
          fill_in_and_save
        }.to change{ project_language.reload.need_entry_count }.from(0).to(1)
      end
    end

  end
  describe "edit" do
    let(:master_text) { create(:master_text, project: project) }
    let(:login) { stubbed_login_as_developer }
    it "displays" do
      visit edit_master_text_path(master_text)
    end
    context "for editor" do
      let(:login) { stubbed_login_as_user }
      it "works" do
        visit edit_master_text_path(master_text)
        expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_changed).with(master_text)
        expect(page).to have_css("form.master_text")
        fill_in "master_text_text", with: 'My new text'
        click_on "Save"
        expect(page).not_to have_css("form.master_text")
      end
    end
    it "works for developer to change key" do
      visit edit_master_text_path(master_text)
      expect(page).to have_css("form.master_text")
      fill_in "master_text_key", with: 'new.key'
      click_on "Save"
      expect(page).not_to have_css("form.master_text")
    end
    describe  "edit with views" do
      let!(:view) { create(:view, project: project, name: "Me") }
      let(:master_text) {create(:master_text, project: project) }
      let!(:other_project) { create(:project) }
      let!(:other_projects_view) { create(:view, project: other_project, name: "Ella") }

      it "works for developer to add view" do
        visit edit_master_text_path(master_text)
        expect(page).to have_css("form.master_text")
        fill_in "master_text_key", with: 'new.key'
        find("#master_text_view_ids_#{view.id}").set(true)
        click_on "Save"
        expect(page).not_to have_css("form.master_text")
        expect(page).to have_content(view.name)
        expect(page).to have_link_to(view_path(view))
      end

      it "only shows view checkboxes from same project" do
        visit edit_master_text_path(master_text)
        expect(page).to have_css("form.master_text")
        expect(page).to have_content(view.name)
        expect(page).to_not have_content(other_projects_view.name)

      end
    end
    it "can change pluralizable" do
      expect_any_instance_of(LocalizedTextEnforcer).to receive(:master_text_changed).with(master_text)
      visit edit_master_text_path(master_text)
      expect(page).to have_css("form.master_text")
      expect {
        page.check('plural')
        click_on "Save"
      }.to change { master_text.reload.pluralizable }
      expect(page).not_to have_css("form.master_text")

    end

    context "when pluralizable" do
      let(:master_text) { create(:master_text, project: project, pluralizable: true) }
      it "allows me to change one" do
        visit edit_master_text_path(master_text)
        fill_in "master_text_one", with: "My one one"
        expect {
          click_on "Save"
        }.to change { master_text.reload.one }
        expect(page).not_to have_css("form.master_text")
      end
      it "allows me to change many" do
        visit edit_master_text_path(master_text)
        fill_in "master_text_other", with: "My other other"
        expect {
          click_on "Save"
        }.to change { master_text.reload.other }
        expect(page).not_to have_css("form.master_text")
      end
    end

    it "displays errors" do
      expect_any_instance_of(LocalizedTextEnforcer).not_to receive(:master_text_changed)
      visit edit_master_text_path(master_text)
      expect(page).to have_css("form.master_text")
      fill_in "master_text_text", with: ''
      click_on "Save"
      expect(page).to have_css("form.master_text")
      expect(page).to have_css("form.master_text .errors")
    end

    it "allows developers to change format" do
      visit edit_master_text_path(master_text)
      expect(page).to have_css("form.master_text")
      select "markdown", from: 'master_text_format'
      click_on "Save"
      expect(master_text.reload.format).to eq("markdown")
    end

    context "with a language..." do
      let!(:project_language) {create(:project_language, project: project, need_review_count: 0)}
      let!(:localized_text) {create(:localized_text, project_language: project_language, master_text: master_text,
          other: "some original translation")}
      it "updates project language review_count" do
        expect {
          visit edit_master_text_path(master_text)
          expect(page).to have_css("form.master_text")
          fill_in "master_text_text", with: 'something new in sandwiches'
          click_on "Save"
          expect(page).not_to have_css("form.master_text")
          expect(localized_text.reload.needs_entry).to be_falsey
          expect(localized_text.reload.needs_review).to be_truthy
        }.to change{ project_language.reload.need_review_count }.from(0).to(1)
      end
    end
  end

  describe "show" do
    let!(:master_text) { create :master_text }
    let!(:localized_texts) { create_list :localized_text, 3, master_text: master_text }

    it "shows multiple languages (and allo" do
      visit master_text_path(master_text)
      all(:link, "Edit").first.click
    end
  end

end
