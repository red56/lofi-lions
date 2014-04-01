require "spec_helper"

describe 'Home page' do

    context "when not logged in" do
      it "redirects to login page" do
        visit '/'
        current_path.should == new_user_session_path
      end
    end

    context "when logged in" do
      before do
        stubbed_login_as_user
      end

    it "works" do
      visit '/'
      current_path.should == '/'
      page.should have_content(@user.email)
    end
    it "has logout" do
      visit '/'
      click_on "Logout"
    end
  end

end
