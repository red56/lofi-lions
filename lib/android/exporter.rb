require "nokogiri"

module Android
  class Exporter < ::BaseExporter
    class ArrayText
      ARRAY_KEY = /\A(.+)\[(\d+)\]\z/o

      def self.===(text)
        super || ARRAY_KEY === text.key
      end

      attr_reader :text, :key, :index

      def initialize(text)
        @text = text
        @key, @index = parse_key
      end

      def parse_key
        m = ARRAY_KEY.match(@text.key)
        raise "Not an array key '#{@text.key}'" if m.nil?
        [m[1], m[2].to_i(10)]
      end

      def other
        @text.other
      end

      def <=>(other)
        case other
        when ArrayText
          index <=> other.index
        else
          key <=> other
        end
      end
    end

    def arrays
      @arrays ||= Hash.new { |h, k| h[k] = [] }
    end

    def body_for(localized_texts)
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.resources do
          localized_texts.each do |text|
            singular_array_plural(xml, text)
          end
          append_arrays(xml)
        end
      end
      builder.to_xml
    end

    def append_arrays(xml)
      arrays.each do |key, texts|
        xml.send(:"string-array", name: key) do
          texts.sort.each do |text|
            xml.item(escape(text.other))
          end
        end
      end
    end

    def singular_array_plural(xml, text)
      if text.pluralizable
        plural(xml, text)
      else
        singular_array(xml, text)
      end
    end

    def singular_array(xml, text)
      case text
      when ArrayText
        array(xml, text)
      else
        singular(xml, text)
      end
    end

    def singular(xml, text)
      xml.string(escape(text.other_export), name: text.key)
    end

    def plural(xml, text)
      xml.plurals(name: text.key) do
        @language.plural_forms_with_fields.each do |key, label|
          xml.item(escape(text.send(key)), quantity: key)
        end
      end
    end


    def array(xml, text)
      ak = ArrayText.new(text)
      arrays[ak.key] << ak
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