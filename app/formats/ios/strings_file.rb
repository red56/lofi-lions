# frozen_string_literal: true

module IOS
  STRINGS_FILE_ENCODING = "BOM|UTF-16LE:UTF-8"

  class StringsFile < BaseParsedFile
    TRAILING_QUOTE = /"\z/.freeze
    NON_ESCAPED_QUOTE = /[^\\]"/.freeze
    SLASH_STAR = Regexp.escape("/*")
    COMMENT_START = /#{SLASH_STAR}\z/.freeze
    TEXT_END = /(#{SLASH_STAR}|\z)/.freeze
    COMMENT_END = Regexp.new(Regexp.escape("*/"))

    # initialize with an IO object - we're mostly going to be
    # creating these from file uploads so best to just deal with the
    # tmpfile instances this gives us
    def initialize(file)
      super(reopen_with_utf16_encoding(file))
    end

    def reopen_with_utf16_encoding(file)
      return File.open(file.path, "rb:#{IOS::STRINGS_FILE_ENCODING}") if file.respond_to?(:path)

      case file
      when IO
        file.set_encoding("rb:#{IOS::STRINGS_FILE_ENCODING}")
        file
      when StringIO
        StringIO.new(file.string.encode(Encoding::UTF_8))
      end
    end

    def parse_file
      localizations = []
      lines.each do |line|
        key, value = parse_line(line)
        localizations << Localization.new(key, value) unless key.nil?
      end
      localizations
    end

    def parse_line(line)
      return [nil, nil] if line.empty?

      scanner = StringScanner.new(line)
      scanner.skip_until(/"/)
      key = scanner.scan_until(NON_ESCAPED_QUOTE).gsub(TRAILING_QUOTE, "")
      scanner.skip(/\s*=\s*"/)
      value = (scanner.scan_until(NON_ESCAPED_QUOTE) || "").gsub(TRAILING_QUOTE, "")
      [key, value].map { |s| unescape(s) }
    end

    def lines
      file_text_without_comments.split(/(\n|\r)/).map { |l| l.strip }
    end

    def file_text_without_comments
      scanner = StringScanner.new(source)
      contents = []
      loop do
        text = scanner.scan_until(TEXT_END)
        contents << text.gsub(COMMENT_START, "")
        scanner.skip_until(COMMENT_END)
        break if scanner.eos?
      end
      contents << scanner.rest
      contents.join.strip
    end

    def source
      @source ||= @file.read
    end

    UNESCAPES = {
      "\\n" => "\n",
      "\\\"" => '"'
    }.freeze

    def unescape(value)
      value.gsub(/(\\n|\\")/, UNESCAPES)
    end
  end
end
