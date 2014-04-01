require 'spec_helper'


describe UsersController do

  before { login }
  let(:login) { stubbed_login_as_admin_user }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end


  context "when not logged in" do
    let(:login) { stubbed_login_as_user }
    it "shows 404" do
      begin
        get :index
        fail('should have raised RoutingError') unless response.status == 404
      rescue ActionController::RoutingError
      end
    end
  end

  describe "index" do
    it "works" do
      get :index
      response.status.should == 200
    end
  end

end
