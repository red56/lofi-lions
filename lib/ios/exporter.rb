
module IOS
  class Exporter < ::Export::Platform
    def localisation(texts)
      strings = ""
      texts.each do |text|
        strings << %("#{escape(text.key)}" = "#{escape(text.other)}";\n)
      end
      strings.encode(Encoding::UTF_8)
    end

    def path
      ::File.join("#{@language.code}.lproj", "Localizable.strings")
    end

    def content_type
      "application/octet-stream"
    end

    ESCAPES = {
      '"' => "\\\"",
      "\n" => "\\n"
    }.freeze

    def escape(other)
      other.gsub(/["\n]/, ESCAPES)
    end
  end
end