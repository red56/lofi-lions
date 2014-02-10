class LocalizedTextsController < ApplicationController

  before_filter :find_language
  def index
    @localized_texts = @language.localized_texts
    @active_tab = :all
  end

  def entry
    @localized_texts = @language.localized_texts.where(text: '')
    @active_tab = :entry
    render :index
  end

  def review
    @localized_texts = @language.localized_texts.where(needs_review: true)
    @active_tab = :review
    render :index
  end

  protected
  def find_language
    @language = Language.find_by_code(params[:language_id])
  end
end