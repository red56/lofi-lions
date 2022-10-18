require "nokogiri"

module Android
  class ResourceFile < BaseParsedFile
    def parse_file
      localizations = []
      @doc = Nokogiri::XML(@file)
      parse_and_append_simple_strings(localizations)
      parse_and_append_plurals(localizations)
      parse_and_append_arrays(localizations)
      localizations
    end

    def parse_and_append_simple_strings(localizations)
      @doc.css("string").each do |node|
        key = node["name"]
        value = unescape(node.text)
        localizations << Localization.new(key, value)
      end
    end

    def parse_and_append_plurals(localizations)
      @doc.css("plurals").each do |node|
        key = node["name"]
        values = Hash[node.css("item").collect do |item_node|
                        plural_form = item_node["quantity"].to_sym
                        value = unescape(item_node.text)
                        [plural_form, value]
                      end]
        localizations << Localization.new(key, values)
      end
    end

    def parse_and_append_arrays(localizations)
      @doc.css("string-array").each do |node|
        base_key = node["name"]
        node.css("item").each_with_index do |item_node, index|
          value = unescape(item_node.text)
          localizations << Localization.new("#{base_key}[#{index}]", value)
        end
      end
    end

    UNESCAPES = {
      "\\'" => "'",
      "\\\"" => '"',
    }

    def unescape(value)
      value.gsub(/(\\'|\\")/, UNESCAPES)
    end
  end
end
