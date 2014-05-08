require 'android'
require 'ios'

module Export
  def self.create(language, platform)
    Exporter.new(language, platform).export
  end

  class MasterTextFallback
    def initialize(master_text)
      @master_text = master_text
    end

    def key
      @master_text.key
    end

    def pluralizable
      @master_text.pluralizable
    end

    def one
      @master_text.one
    end

    Language.plurals.reject { |form| form == :one }.each do |form|
      module_eval (<<-RB)
        def #{form}
          @master_text.other
        end
      RB
    end
  end

  class Exporter
    def initialize(language, platform)
      @language= language
      @platform_name = platform
    end

    def export
      texts = master_texts.map { |mt| texts_with_mt_fallback(mt) }
      platform.export_language(texts)
    end

    def texts_with_mt_fallback(master_text)
      master_text.localized_texts.where(language: @language).first || MasterTextFallback.new(master_text)
    end

    def master_texts
      @master_texts ||= MasterText.order(:key).all
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