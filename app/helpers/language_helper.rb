module LanguageHelper
  def languages
    @languages ||= Language.all
  end
end