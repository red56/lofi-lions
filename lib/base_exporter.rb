class BaseExporter
  def initialize(language, project)
    @language = language
    @project = project
    @project_language = if @language.is_master_text?
      ProjectLanguage.for_master_texts(@language, @project)
    else
      ProjectLanguage.where(language_id: language.id, project_id: project.id).first or fail "No ProjectLanguage"
    end
  end

  def body
    body_for(@project_language.localized_texts_with_fallback)
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