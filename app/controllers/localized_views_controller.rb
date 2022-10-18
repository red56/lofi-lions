# frozen_string_literal: true

class LocalizedViewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_languages_section

  before_action :find_project_language

  def index
    @active_tab = :view
    @views = @project_language.project.views
  end

  def show
    @active_tab = :view
    @view = View.find(params[:id])
    @localized_texts = @project_language.localized_texts.where(master_text_id: @view.master_texts.pluck(:id)).includes(:master_text, :views)
  end

  protected

  def find_project_language
    @project_language = ProjectLanguage.find(params[:project_language_id])
  end
end
