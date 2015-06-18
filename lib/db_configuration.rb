#NB need to specify a username in the database.yml if you want to use any of these commands
module DbConfiguration
  class << self
    def config
      @@db_configuration ||= RailsYamlFormat.load(
          ERB.new(
              File.read(
                  File.expand_path('../../config/database.yml', __FILE__)
              )
          ).result
      )
    end
  end
end