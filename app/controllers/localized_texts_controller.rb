# frozen_string_literal: true

class LocalizedTextsController < ApplicationController
  include NextLocalizedText
  before_action :authenticate_user!
  before_action :set_languages_section
  before_action :find_localized_text, only: [:update, :flow, :edit]
  before_action :find_language, only: [:index, :entry, :review]

  def index
    @localized_texts = localized_texts
    @active_tab = :all
  end

  def entry
    @localized_texts = localized_texts.where(needs_entry: true)
    if @project_language.need_entry_count > 0
      @header = "#{@project_language.need_entry_count} to enter"
    else
      @header = "All entered"
    end
    @active_tab = :entry
    render :index
  end

  def review
    @localized_texts = localized_texts.where(needs_review: true)
    if @project_language.need_review_count > 0
      @header = "#{@project_language.need_review_count} to review"
    else
      @header = "All reviewed"
    end
    @active_tab = :review
    render :index
  end

  def edit
    @original_url = request.referer
  end

  def flow
    @active_tab = :overview
    render :edit
  end

  def update
    @localized_text.update_attributes!(localized_texts_params)
    @localized_text.project_language.recalculate_counts!
    redirect_to next_path_after_update
  end

  protected

  attr_reader :project_language

  def next_path_after_update
    return params[:original_url] if params[:original_url]

    next_localized_text_or_project_language_path(@localized_text.key)
  end

  def localized_texts
    @project_language.localized_texts.includes(:master_text).order(Arel.sql("LOWER(master_texts.key)")).references(:master_texts)
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

  def find_localized_text
    @localized_text = LocalizedText.find(params[:id])
    @project_language = @localized_text.project_language
  end
end
