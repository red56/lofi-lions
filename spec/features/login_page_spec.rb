# frozen_string_literal: true

require "rails_helper"

describe "Login pages", type: :feature do
  context "when logs in" do
    before do
      visit new_user_session_path
      fill_in :user_email, with: user.email
      fill_in :user_password, with: user.password
      click_on "Log in"
    end

    context "as standard user" do
      let(:user) { create(:user) }

      it "goes to dashboard page" do
        expect(current_path).to eq(root_path)
      end
    end
  end
end
