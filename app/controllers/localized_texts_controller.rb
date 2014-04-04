class LocalizedTextsController < ApplicationController
  before_action :set_languages_section

  before_filter :find_language
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

  protected
  def localized_texts
    @language.localized_texts.includes(:master_text).order('LOWER(master_texts.key)').references(:master_texts)
  end

  def find_language
    @language = Language.find_by_code(params[:language_id])
  end
end