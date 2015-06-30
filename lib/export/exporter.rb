class Export::Exporter
  def self.export(language, platform)
    new(language, platform).export
  end

  def initialize(language, platform)
    @language= language
    @platform_name = platform
  end

  def export
    texts = master_texts.map { |mt| texts_with_mt_fallback(mt) }
    platform.export_language(texts)
  end

  def texts_with_mt_fallback(master_text)
    master_text.localized_texts.where(language: @language).first || ::Export::MasterTextFallback.new(master_text)
  end

  def master_texts
    @master_texts ||= MasterText.order(:key)
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
