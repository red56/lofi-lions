require 'localization'

class AndroidResourceFile
  def self.parse(file)
    Parser.new(file)
  end

  class Parser
    def initialize(file)
    end
  end
end