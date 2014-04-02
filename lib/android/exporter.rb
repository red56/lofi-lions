require 'export/platform'
require 'nokogiri'

module Android
  class Exporter < ::Export::Platform
    def localisation(texts)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.resources do
          texts.each do |text|
            xml.string(escape(text.other), name: text.key)
          end
        end
      end
      builder.to_xml
    end

    def path
      values = @language.code == "en" ? "values" : "values-#{@language.code}"
      ::File.join("res", values, "strings.xml")
    end

    def content_type
      "text/xml"
    end

    ESCAPES = {
      "'" => "\\'",
      '"' => "\\\""
    }.freeze

    def escape(other)
      other.gsub(/['"]/, ESCAPES)
    end
  end
end