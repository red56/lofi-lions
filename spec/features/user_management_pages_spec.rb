require "rails_helper"

describe "User management pages", type: :feature do

  before { login }
  let(:login) { stubbed_login_as_admin_user }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit users_path
      expect(current_path).to eq(new_user_session_path)
    end
  end


  context "when logged in as non-admin" do
    let(:login) { stubbed_login_as_user }
    it "redirects to login page" do

      visit users_path
      expect(page.status_code).to eq(404)
    rescue ActionController::RoutingError


    end

    specify "index is not linked from homepage" do
      visit "/"
      expect(page).not_to have_link_to(users_path)
    end
  end

  specify "index is linked from homepage" do
    visit "/"
    expect(page).to have_link_to(users_path)
  end

  describe "index" do
    let(:users) { build_stubbed_list(:user, 3) }
    before do
      allow(User).to receive_messages(all: users)
      allow_to_behave_like_scope(users)
    end

    specify "lists users" do
      visit users_path
      users.each do |user|
        expect(page).to have_content(user.email)
        expect(page).to have_link_to(edit_user_path(user))
      end
    end
    context "with project langaguges" do
      let(:project_languages) { [build_stubbed(:project_language,
          project: build_stubbed(:project, name: "projecty"),
          language: build_stubbed(:language, name: "fingle"))]}
      specify "lists users with editing privileges" do
        expect(users.last).to receive_messages(project_languages: like_a_scope(project_languages))
        visit users_path
        expect(page).to have_content("fingle")
      end
    end

    it "has link to add" do
      visit users_path
      click_on "Add"
      expect(page.current_path).to eq(new_user_path)
    end
  end

  describe "new" do
    it "can create new user" do
      visit new_user_path
      nonsense = "flongtibong@example.com"
      fill_in :user_email, with: nonsense
      click_on "Save"
      expect(current_path).to eq(users_path)
      expect(page).to have_content(nonsense)
    end
  end

  describe "edit" do
    let(:user) { create(:user) }
    let(:project) {create :project }
    let(:languages) { create_list(:language, 3) }
    let(:project_languages) { languages.map { |language| create :project_language, language: language, project: project } }
    it "can change details" do
      visit edit_user_path(user)
      nonsense = "flongtibong@example.com"
      fill_in :user_email, with: nonsense
      click_on "Save"
      expect(current_path).to eq(users_path)
      expect(page).to have_content(nonsense)
    end
    context "if not admin" do
      let(:login) { stubbed_login_as_user }

      it "can't view if not admin" do
        expect { visit edit_user_path(user) }.to raise_error(ActionController::RoutingError)
      end
    end

    it "user to be admin" do
      visit edit_user_path(user)
      find("#user_is_administrator").set(true)
      find("#user_edits_master_text").set(true)
      find("#user_is_developer").set(true)
      click_on "Save"
      expect(current_path).to eq(users_path)
      within ("#user_#{user.id}") do
        expect(page).to have_content("Admin")
        expect(page).to have_content("English")
        expect(page).to have_content("Dev")
      end
    end
    it "user to be specific language editor" do
      project_languages
      visit edit_user_path(user)
      project_languages.each do |project_language|
        find("#user_project_language_ids_#{project_language.id}").set(true)
      end
      click_on "Save"
      expect(current_path).to eq(users_path)
      project_languages.each do |project_language|
        expect(page).to have_content(project_language.language.name)
      end
    end
  end
end
