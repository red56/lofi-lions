require File.expand_path('../../thor_utils', __FILE__)

class ImportThor < Thor
  include ThorUtils

  no_commands {
    def localizations(code, filename)
      require './config/environment'

      language = Language.find_by_code(code)
      if language.nil?
        puts "Error: Couldn't find language code '#{code}'"
        return
      end
      io_from_filename(filename) do |io|
        localizations = yield(io)
        errors = Localization.create_localized_texts(language, localizations)
        unless errors.empty?
          puts "Errors occurred:"
          errors.each_with_index do |error, index|
            puts "%-3d #{error}" % [index+1]
          end
        end
      end
    end
  }

  class Ios < Thor
    namespace :ios
    desc "localizations CODE FILE", "imports localization files into backend"

    def localizations(code, filename="-")
      ImportThor.new.localizations(code, filename) do |io|
        StringsFile.parse(io)
      end
    end
  end

  class Android < Thor
    namespace :android
    desc "localizations CODE FILE", "imports localization files into backend"

    def localizations(code, filename="-")
      ImportThor.new.localizations(code, filename) do |io|
        AndroidResourceFile.parse(io)
      end
    end
  end
end