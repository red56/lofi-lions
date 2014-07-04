require "spec_helper"

describe 'User management pages' do

  before { login }
  let(:login) { stubbed_login_as_admin_user }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit users_path
      current_path.should == new_user_session_path
    end
  end


  context "when not logged in" do
    let(:login) { stubbed_login_as_user }
    it "redirects to login page" do
      begin
        visit users_path
        page.status_code.should == 404
      rescue ActionController::RoutingError
      end

    end
  end

  describe "index" do
    let(:users) { build_stubbed_list(:user, 3) }
    before do
      User.stub(all: users)
    end

    specify "lists users" do
      visit users_path
      users.each do |user|
        page.should have_content(user.email)
      end
    end

    specify "lists users" do
      visit users_path
      users.each do |user|
        page.should have_link_to(edit_user_path(user))
      end
    end

    pending "has link to add" do
      pending "not yet"
      visit users_path
      click_on "Add"
      page.current_path.should == new_user_path
    end
  end

  describe "new" do
    specify "can create new user"
  end

  describe "edit" do
    specify "can specify email address to be master text editor"
    specify "can specify email address to be specific language editor"
  end
end