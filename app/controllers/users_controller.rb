class UsersController < ApplicationController
  before_action :require_administrator!

  def index
    @users = User.all
  end

  def require_administrator!
    authenticate_user!
    raise ActionController::RoutingError.new('Not Found') unless current_user.is_administrator
  end
end