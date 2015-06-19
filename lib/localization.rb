# Represents an abstract localisation
# Generated by parsing a localization file from an app
# Used to generate localization files for use in an app
class Localization

  attr_reader :key, :value

  def initialize(key, value)
    @key, @value = key, value
  end

  alias_method :text, :value

  def to_a
    [key, value]
  end

  def to_s
    "Localization[#{key}]:'#{value}'"
  end

  include Comparable
  def <=> other
    return [key, value] <=> [other.key, other.value]
  end

  def self.create_master_texts(localizations)
    localizations.each do |localization|
      LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(localization.key, localization.text)
    end
  end
  def self.create_localized_texts(language, localizations)
    errors = {}
    localizations.each do |localization|
      master_text = MasterText.find_by_key(localization.key)
      if master_text.nil?
        errors[localization.key] = "couldn't find master text"
      else
        localized_text = LocalizedText.find_or_initialize_by(master_text_id: master_text.id, language_id: language.id)
        if localization.value.is_a?(Hash)
          localized_text.update_attributes!(localization.value)
        else
          localized_text.update_attributes!(other: localization.value)
        end
      end
    end
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
      Hash[localizations.map { |l| [l.key, l] }]
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