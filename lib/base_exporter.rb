class BaseExporter
  def initialize(language)
    @language = language
  end

  def export_language(texts)
    [localisation(texts), path, content_type]
  end

  def self.export(language, platform)
    platform_class(platform).new(language).export_language(language.localized_texts_with_fallback)
  end

  def self.platform_class(platform)
    case platform
      when "android", :android
        Android::Exporter
      when "ios", :ios
        IOS::Exporter
    end
  end
end