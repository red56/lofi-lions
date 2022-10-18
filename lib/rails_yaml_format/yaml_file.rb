# frozen_string_literal: true

module RailsYamlFormat
  class YamlFile < BaseParsedFile
    def initialize(file)
      @file = case file
              when ActionDispatch::Http::UploadedFile
                File.open(file.tempfile)
              when File
                file
              else
                File.open(file)
              end
    end

    def parse_file
      localizations = []
      hash = YAML::load(@file)
      # the top level of this will always be a language name with a set of keys
      add_hash_to_localizations(hash.values.first, localizations: localizations)
      localizations
    end

    private

    def add_hash_to_localizations(hash, localizations:, keys: [])
      hash.each_pair do |key, value|
        if key.nil?
          next
        elsif value.respond_to?(:each_pair)
          add_hash_to_localizations(value, localizations: localizations, keys: keys + [key])
        else
          localizations << Localization.new((keys + [key]).join("/"), value)
        end
      end
    end
  end
end
