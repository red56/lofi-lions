require 'localization'

class AndroidResourceFile
  def self.parse(file)
    Parser.new(file)
  end

  class Parser < Localization::Collection
    def initialize(file)
      @file = file
    end

    def localizations
      @localizations ||= parse_file
    end

    def parse_file
      Nokogiri::XML(@file).css("string").collect do |node|
        key = node['name']
        value = node.text
        Localization.new(key, value)
      end
    end
  end
end