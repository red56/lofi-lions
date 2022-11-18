# frozen_string_literal: true

class BaseExporter
  def initialize(language, project)
    @language = language
    @project = project
  end

  def body
    if @language.is_master_text?
      body_for(@project.master_texts_impersonating_localized_texts)
    elsif @language.code == Language::XX_CODE_FOR_TESTING
      body_for(@project.master_texts_as_xx)
    else
      project_language = ProjectLanguage.where(language_id: @language.id, project_id: @project.id).first
      raise "No ProjectLanguage" unless project_language

      body_for(project_language.localized_texts_with_fallback)
    end
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
      raise "Not expecting #{platform}"
    end
  end
end
