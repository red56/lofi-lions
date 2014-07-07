module LanguageHelper
  def languages
    @languages ||= Language.all
  end
  def views
    @views ||= View.all
  end
end