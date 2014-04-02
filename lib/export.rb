require 'android'
require 'ios'

module Export
  def self.create(language, platform)
    Exporter.new(language, platform).export
  end

  class Exporter
    def initialize(language, platform)
      @language= language
      @platform_name = platform
    end

    def export
      texts = master_texts.map { |mt| mt.localized_texts.where(language: @language).first }
      platform.export_language(texts)
    end

    def master_texts
      @master_texts ||= MasterText.all
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
end