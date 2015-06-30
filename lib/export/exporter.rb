class Export::Exporter
  def self.export(language, platform)
    new(language, platform).export
  end

  def initialize(language, platform)
    @language= language
    @platform_name = platform
  end

  def export
    platform.export_language(localized_texts_with_fallback)
  end

  def localized_texts_with_fallback
    MasterText.order(:key).map { |mt| localized_text_with_fallback(mt) }
  end

  def localized_text_with_fallback(master_text)
    master_text.localized_texts.where(language: @language).first || ::Export::MasterTextFallback.new(master_text)
  end

  def platform
    @platform ||= platform_exporter_class.new(@language)
  end

  def platform_exporter_class
    case @platform_name
      when "android", :android
        Android::Exporter
      when "ios", :ios
        IOS::Exporter
    end
  end
end
