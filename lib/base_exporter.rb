class BaseExporter
  def initialize(language, project)
    @language = language
    @project = project
  end

  def body
    body_for(@language.localized_texts_with_fallback(@project))
  end

  def self.class_for(platform)
    case platform.to_s
      when "android"
        Android::Exporter
      when "ios"
        IOS::Exporter
      when "yaml"
        RailsYamlFormat::Exporter
      else
        fail "Not expecting #{platform}"
    end
  end
end