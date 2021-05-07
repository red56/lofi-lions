class ProjectLanguagesController < ApplicationController
  include NextLocalizedText
  before_action :authenticate_user!
  before_action :find_project_language, only: [:update, :show, :next]

  def index
    if current_user.edits_master_text? || current_user.is_administrator? || current_user.is_developer?
      @project_languages = ProjectLanguage.all
    else
      @project_languages = current_user.project_languages
    end
    @project_languages = @project_languages.includes(:project, :language).order('languages.name, projects.id')
  end

  def show
    @active_tab = :overview
  end

  def update
    respond_to do |format|
      if @project_language.update(project_language_params)
        @project_language.recalculate_counts!
        format.html { redirect_to next_page_after_update, notice: "#{@project_language} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def next
    raise "missing params[:flow]" if params[:flow].blank?
    redirect_to next_localized_text_or_project_language_path(params[:key])
  end

  private

  attr_reader :project_language

  def next_page_after_update
    return request.referer if request.referer
    project_language_path(@project_language)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_language_params
    params.require(:project_language).permit(
        localized_texts_attributes: [:text, :zero, :one, :two, :few, :many, :other, :needs_review, :id]
    )
  end

  def find_project_language
    @project_language = ProjectLanguage.find(params[:id])
  end
end
