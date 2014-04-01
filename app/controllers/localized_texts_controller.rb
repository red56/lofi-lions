class LocalizedTextsController < ApplicationController

  before_filter :find_language
  def index
    @localized_texts = @language.localized_texts.includes(:master_text)
    @active_tab = :all
  end

  def entry
    @localized_texts = @language.localized_texts.includes(:master_text).where(needs_entry: true)
    @active_tab = :entry
    render :index
  end

  def review
    @localized_texts = @language.localized_texts.includes(:master_text).where(needs_review: true)
    @active_tab = :review
    render :index
  end

  protected
  def find_language
    @language = Language.find_by_code(params[:language_id])
  end
end