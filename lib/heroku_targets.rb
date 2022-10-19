# frozen_string_literal: true

require "active_support/all"
class HerokuTargets
  class << self
    def from_string(heroku_targets_yml)
      HerokuTargets.new(YAML.safe_load(heroku_targets_yml))
    end

    def from_file(yaml_file)
      HerokuTargets.new(YAML.safe_load(File.read(yaml_file)))
    end
  end

  attr_reader :targets, :staging_targets

  DEFAULTS_KEY = "_defaults"

  def initialize(targets_hash)
    defaults = if targets_hash.keys.first == DEFAULTS_KEY
                 targets_hash.delete(DEFAULTS_KEY)
               else
                 {}
               end
    @targets = TargetsContainer[targets_hash.collect { |name, values|
                                  heroku_target = HerokuTarget.new(defaults.merge(values), name)
                                  [heroku_target.heroku_app, heroku_target]
                                }].freeze
    @staging_targets = TargetsContainer[@targets.select { |_name, target| target.staging? }]
  end

  class TargetsContainer < ActiveSupport::HashWithIndifferentAccess
    def [](key)
      return super if key?(key)

      values.each do |value|
        return value if value.name.to_s == key.to_s
      end
      nil
    end
  end

  class HerokuTarget
    attr_reader :name

    def initialize(values_hash, name = nil)
      @values = values_hash.symbolize_keys.freeze
      @name = name.to_sym if name
      %i(heroku_app git_remote deploy_ref).each do |required_name|
        raise required_value(required_name) unless @values[required_name]
      end
    end

    def required_value(required_name)
      ArgumentError.new("please specify '#{required_name}:' ")
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

    def database_url
      @values[:database_url]
    end

    def git_remote
      @values[:git_remote]
    end

    def deploy_ref
      @values[:deploy_ref]
    end

    def db_color
      @values[:db_color] || "DATABASE"
    end

    def repository
      @values[:repository] || raise(required_value(:repository))
    end

    def to_s
      display_name
    end

    def dump_filename
      File.expand_path("../../tmp/latest_#{heroku_app}_backup.dump", __FILE__)
    end
  end
end
