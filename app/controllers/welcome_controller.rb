class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def docs
    redirect_to root_path unless current_user.is_developer?
  end

  def index
  end
end
