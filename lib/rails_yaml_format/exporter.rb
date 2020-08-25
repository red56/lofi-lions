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

      lower_level_hash = Hash[localized_texts.map {|text|[text.key, text.other_export] }]

      top_level_hash[@language.code] = lower_level_hash
      top_level_hash.to_yaml
    end
  end
end
