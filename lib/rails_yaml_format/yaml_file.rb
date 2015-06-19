module RailsYamlFormat

  class YamlFile < BaseParsedFile

    def parse_file
      localizations = []
      hash = YAML::load(File.open(@file))
      # the top level of this will always be a language name with a set of keys
      # for now, we are only worrying about the top-level of keys (ignoring nested stuff)
      hash.values.first.each do |key, value|
        localizations << Localization.new(key, value) unless key.nil?
      end
      localizations
    end
  end
end