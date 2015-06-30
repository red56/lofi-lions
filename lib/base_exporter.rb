class BaseExporter
  def initialize(language)
    @language = language
  end

  def body
    body_for(@language.localized_texts_with_fallback)
  end

  def self.class_for(platform)
    case platform
      when "android", :android
        Android::Exporter
      when "ios", :ios
        IOS::Exporter
    end
  end
end