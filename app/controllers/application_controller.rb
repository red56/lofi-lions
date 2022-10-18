# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protected

  def set_languages_section
    @section = "languages"
  end

  def set_master_text_tab
    @active_tab = :master_text
  end

  def set_users_section
    @section = "users"
  end

  def set_view_tab
    @active_tab = :view
  end

  def require_administrator!
    authenticate_user!
    raise ActionController::RoutingError.new("Not Found") unless current_user.is_administrator?
  end

  def require_developer!
    authenticate_user!
    raise ActionController::RoutingError.new("Not Found") unless current_user.is_developer?
  end
end
