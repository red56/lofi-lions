class LocalizedTextsController < ApplicationController

  def index
    @language = Language.find_by_code(params[:language_id])
    @localized_texts = @language.localized_texts
  end
end