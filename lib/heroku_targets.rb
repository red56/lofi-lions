require 'active_support/all'
class HerokuTargets

  class << self
    def from_string(heroku_targets_yml)
      HerokuTargets.new(YAML.load(heroku_targets_yml))
    end
    def from_file(yaml_file)
      HerokuTargets.new(YAML.load(File.read(yaml_file)))
    end
  end

  attr_reader :targets, :staging_targets

  def initialize(targets_hash)
    @targets = Hash[targets_hash.collect { |name, values| [name.to_sym, HerokuTarget.new(values)] }].freeze
    @staging_targets = @targets.select { |name, target| target.staging? }
  end

  class HerokuTarget
    def initialize(values_hash)
      @values = values_hash.symbolize_keys.freeze
      [:heroku_app, :git_remote, :deploy_ref].each do |required_name|
        raise ArgumentError.new("please specify '#{required_name}:' ") unless @values[required_name]
      end
    end

    def staging?
      @values[:staging]
    end

    def display_name
      @values[:display_name] || @values[:heroku_app]
    end

    def heroku_app
      @values[:heroku_app]
    end

    def git_remote
      @values[:git_remote]
    end

    def deploy_ref
      @values[:deploy_ref]
    end

    def to_s
      display_name
    end

    def dump_filename
      File.expand_path("../../tmp/latest_#{heroku_app}_backup.dump", __FILE__)
    end
  end
end