class ProjectsController < ApplicationController
  before_action :find_project
  before_action :require_administrator!, except: [:show]

  def show
    @active_tab = :overview
  end

  def edit
    @active_tab = :edit
  end

  def update
    if update_project_with_languages
      redirect_to @project
    else
      @active_tab = :edit
      render :edit
    end
  end

  protected
  def find_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).except(:language_ids).permit(:name, :description)
  end

  def update_project_with_languages
    @project.update(project_params).tap do |success|
      if success
        project_language_id_params.each do |id|
          if @language = get_additional_language(id)
            project_language = ProjectLanguage.new(project: @project, language: @language)
            LocalizedTextEnforcer::ProjectLanguageCreator.new(project_language).save or fail ("failed to create ProjectLanguage")
          end
        end
      end
    end
  end

  def project_language_id_params
    params[:project][:language_ids]
  end

  def get_additional_language(language_id)
    return nil unless language_id.present? && @language = Language.where(id: language_id).first
    return nil if @project.languages.include?(@language)
    @language
  end
end
