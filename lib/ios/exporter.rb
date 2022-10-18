module IOS
  class Exporter < ::BaseExporter
    def body_for(localized_texts)
      strings = ""
      localized_texts.each do |text|
        strings << %("#{escape(text.key)}" = "#{escape(text.other_export)}";\n)
      end
      "\xFF\xFE".force_encoding(encoding) << strings.encode(encoding)
    end

    def path
      ::File.join("#{@language.code}.lproj", "Localizable.strings")
    end

    def content_type
      "application/octet-stream; charset=#{Encoding::UTF_16.name}"
    end

    ESCAPES = {
      '"' => "\\\"",
      "\n" => "\\n"
    }.freeze

    def escape(other)
      other.gsub(/["\n]/, ESCAPES)
    end

    def encoding
      Encoding::UTF_16LE
    end
  end
end
