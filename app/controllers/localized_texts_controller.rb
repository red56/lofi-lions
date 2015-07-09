class LocalizedTextsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_languages_section
  before_filter :find_language, only: [:index, :entry, :review]


  def index
    @localized_texts = localized_texts
    @active_tab = :all
  end

  def entry
    @localized_texts = localized_texts.where(needs_entry: true)
    @active_tab = :entry
    render :index
  end

  def review
    @localized_texts = localized_texts.where(needs_review: true)
    @active_tab = :review
    render :index
  end

  def edit
    @original_url = request.referer
    @localized_text = LocalizedText.find(params[:id])
  end

  def update
    @localized_text = LocalizedText.find(params[:id])
    @localized_text.update_attributes!(localized_texts_params)
    @project_language = @localized_text.project_language
    redirect_to params[:original_url]
  end

  protected
  def localized_texts
    @project_language.localized_texts.includes(:master_text).order('LOWER(master_texts.key)').references(:master_texts)
  end

  def find_language
    @project_language = ProjectLanguage.find(params[:project_language_id])
  end

  def localized_texts_params
    params.require(:localized_text).permit(
        :comment, :few, :many, :master_text_id, :needs_entry, :needs_review, :one, :other, :two, :zero,
        :project_language_id
    )
  end
end