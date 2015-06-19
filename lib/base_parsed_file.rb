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
end