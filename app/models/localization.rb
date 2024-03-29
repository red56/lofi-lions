# frozen_string_literal: true

# Represents an abstract localisation
# Generated by parsing a localization file from an app
# Used to generate localization files for use in an app
class Localization
  attr_reader :key, :value

  def initialize(key, value)
    @key = key
    @value = value
  end

  alias text value

  def to_a
    [key, value]
  end

  def to_s
    "Localization[#{key}]:'#{value}'"
  end

  include Comparable
  def <=>(other)
    [key, value] <=> [other.key, other.value]
  end

  def self.create_master_texts(localizations, project)
    localizations.each do |localization|
      LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(localization.key, localization.text, project.id)
    end
    project.recalculate_counts!
  end

  def self.create_localized_texts(language, localizations, project_id)
    errors = {}
    project_language = ProjectLanguage.where(language_id: language.id, project_id: project_id).first
    raise "Couldn't find ProjectLanguage" unless project_language

    localizations.each do |localization|
      master_text = MasterText.where(key: localization.key, project_id: project_id).first
      if master_text.nil?
        errors[localization.key] = "couldn't find master text"
      else
        localized_text = LocalizedText.find_or_initialize_by(master_text_id: master_text.id, project_language_id: project_language.id)
        if localization.value.is_a?(Hash)
          localized_text.update!(localization.value)
        else
          localized_text.update!(other: localization.value)
        end
      end
    end
    project_language.recalculate_counts!
    errors
  end

  module Collection
    def keys
      localizations.map(&:key)
    end

    def values
      localizations.map(&:value)
    end

    def to_a
      localizations.dup
    end

    def to_hash
      localizations.index_by(&:key)
    end

    def each(&block)
      localizations.each(&block)
    end
  end

  class CollectionWrappingArray
    include Collection
    attr_reader :localizations

    def initialize(localizations)
      @localizations = localizations
    end
  end
end
