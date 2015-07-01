require 'rails_helper'

describe 'User management pages', :type => :feature do

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
      begin
        visit users_path
        expect(page.status_code).to eq(404)
      rescue ActionController::RoutingError
      end

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
      allow(users).to receive_messages(includes: users, order:users)
    end

    specify "lists users" do
      visit users_path
      users.each do |user|
        expect(page).to have_content(user.email)
        expect(page).to have_link_to(edit_user_path(user))
      end
    end
    specify "lists users with editing privileges" do
      expect(users.last).to receive_messages(languages: [build_stubbed(:language, name: 'fingle')])
      visit users_path
      expect(page).to have_content('fingle')
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
    let(:languages) { create_list(:language, 3) }
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
        expect{visit edit_user_path(user)}.to raise_error
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
        expect(page).to have_content('Admin')
        expect(page).to have_content('English')
        expect(page).to have_content('Dev')
      end
    end
    it "user to be specific language editor" do
      languages
      visit edit_user_path(user)
      languages.each do |language|
        find("#user_language_ids_#{language.id}").set(true)
      end
      click_on "Save"
      expect(current_path).to eq(users_path)
      languages.each do |language|
        expect(page).to have_content(language.name)
      end
    end
  end
end