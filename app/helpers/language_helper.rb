# frozen_string_literal: true

module LanguageHelper
  def languages
    @languages ||= Language.all
  end

  def views
    @views ||= View.all
  end

  def projects
    @projects ||= Project.all
  end
end
