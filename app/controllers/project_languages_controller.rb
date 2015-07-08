class ProjectLanguagesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project_language, only: [:update, :show]

  def index
    redirect_to root_path
  end

  def show
    @active_tab = :overview
  end

  def update
    respond_to do |format|
      if @project_language.update(project_language_params)
        @project_language.recalculate_counts!
        format.html { redirect_to languages_path, notice: 'Language was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  private

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
