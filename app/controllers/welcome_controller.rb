class WelcomeController < ApplicationController
  def index
    if !user_signed_in?
      redirect_to new_user_session_path
    else
      redirect_to dashboard_path
    end
  end

  def dashboard

  end
end