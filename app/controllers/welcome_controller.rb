class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def docs
    redirect_to root_path unless current_user.is_developer?
  end

  def index
    if current_user.edits_master_text? || current_user.is_administrator? || current_user.is_developer?
      @projects = Project.all.includes(:languages).order(:id)
    end
    @project_languages = current_user.project_languages.includes(:project)
  end
end
