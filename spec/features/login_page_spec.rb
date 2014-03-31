require "spec_helper"

describe 'Login pages' do

  context "when not logged in" do
    it "doesn't have link to sign up path" do
        visit new_user_session_path
      expect {
        @has_link = page.has_link_to?(new_user_registration_path)
      }.to raise_error
      @has_link.should be_false
    end
    it "sign up path doesn't work" do
      expect {
        visit new_user_registration_path
        @is_404 = page.status_code == 404
      }.to raise_error
      @is_404.should be_false
    end
  end
end
