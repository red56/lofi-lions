# frozen_string_literal: true

module RailsYamlFormat
  class Exporter < ::BaseExporter
    def path
      "config/locales/#{@language.code}.yml"
    end

    def content_type
      "text/yaml; charset=utf-8"
    end

    def body_for(localized_texts)
      top_level_hash = {}
      # lower_level_hash = Hash[localized_texts.map {|text|[text.key, text.other_export] }]
      lower_level_hash = {}
      localized_texts.each do |text|
        add_to_hash(lower_level_hash, keys: text.key.split("/"), value: text.other_export)
        # lower_level_hash[text.key] = text.other_export
      end

      top_level_hash[@language.code_for_top_level_rails_hash] = lower_level_hash
      top_level_hash.to_yaml
    end

    def add_to_hash(hash, keys:, value:)
      key = keys.shift
      if keys.empty?
        hash[key] = value
      else
        add_to_hash(hash[key] ||= {}, keys: keys, value: value)
      end
    end
  end
end
