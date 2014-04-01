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
      localizations = []
      doc = Nokogiri::XML(@file)
      doc.css("string").each do |node|
        key = node['name']
        value = node.text
        localizations << Localization.new(key, value)
      end
      doc.css("plurals").each do |node|
        key = node['name']
        values = Hash[node.css('item').collect do |item_node|
          plural_form = item_node['quantity'].to_sym
          value = item_node.text
          [plural_form, value]
        end]
        localizations<< Localization.new(key, values)
      end
      localizations
    end
  end
end