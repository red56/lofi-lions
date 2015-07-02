class LocalizedViewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_languages_section

  before_filter :find_language

  def index
    @active_tab = :view
  end
  def show
    @active_tab = :view
    @view = View.find(params[:id])
    @localized_texts = @language.localized_texts.where(master_text_id: @view.master_texts.pluck(:id)).includes(:master_text, :views)
  end
  protected
  def find_language
    @language = Language.find_by_code(params[:language_id])
  end

end