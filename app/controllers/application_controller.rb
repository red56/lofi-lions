class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_languages_section
    @section = "languages"
  end

  def set_master_texts_section
    @section = "master-texts"
  end

  def set_users_section
    @section = "users"
  end

end
