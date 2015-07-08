require 'rails_helper'

describe 'Login pages', :type => :feature do

  context "when not logged in" do
    it "doesn't have link to sign up path" do
      visit new_user_session_path
      expect {
        @has_link = page.has_link_to?(new_user_registration_path)
      }.to raise_error
      expect(@has_link).to be_falsey
    end
    it "sign up path doesn't work" do
      expect {
        visit new_user_registration_path
        @is_404 = page.status_code == 404
      }.to raise_error
      expect(@is_404).to be_falsey
    end
  end

  context "when logs in " do
    before do
      visit new_user_session_path
      fill_in :user_email, with: user.email
      fill_in :user_password, with: user.password
      click_on "Sign in"
    end
    context "as standard user" do
      let(:user) { create(:user) }
      it "goes to dashboard page" do
        expect(current_path).to eq(root_path)
      end
    end
  end
end
