class BaseParsedFile

  include Localization::Collection

  def self.parse(file)
    self.new(file)
  end

  def initialize(file)
    @file = file
  end

  def localizations
    @localizations ||= parse_file
  end

  def close
    @file.close if @file
  end

  def self.class_for(platform)
    case platform.to_s
      when "android"
        Android::ResourceFile
      when "ios"
        IOS::StringsFile
      when "yaml"
        RailsYamlFormat::YamlFile
      else
        fail "Not expecting #{platform}"
    end
  end

end