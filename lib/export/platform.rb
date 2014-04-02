module Export
  class Platform
    def initialize(language)
      @language = language
    end

    def export_language(texts)
      [localisation(texts), path, content_type]
    end
  end
end