# frozen_string_literal: true

require File.expand_path("../../heroku_targets", __FILE__)
require File.expand_path("../../../lib/db_configuration", __FILE__)
require File.expand_path("../../../config/initializers/00-version", __FILE__)

class Heroku < Thor
  module Shared
    def self.exit_on_failure?
      true
    end

    def lookup_heroku_staging(staging_target_name)
      heroku_targets.staging_targets[staging_target_name] || raise_missing_target(staging_target_name, true)
    end

    def lookup_heroku(target_name)
      heroku_targets.targets[target_name] || raise_missing_target(target_name, false)
    end

    def check_deploy_ref(deploy_ref, target)
      raise Thor::Error.new("Invalid deploy ref '#{deploy_ref}'") if deploy_ref && deploy_ref[0] == "-"
      deploy_ref || target.deploy_ref
    end

    def raise_missing_target(target_name, staging)
      if staging
        description = "Staging target_name '#{target_name}'"
        targets = heroku_targets.staging_targets.keys
      else
        description = "Target '#{target_name}'"
        targets = heroku_targets.targets.keys
      end
      msg = "#{description} was not found. Valid targets are #{targets.collect { |t| "'#{t}'" }.join(',')}"
      raise Thor::Error, msg
    end

    def heroku_targets
      @heroku_targets ||= HerokuTargets.from_file(File.expand_path("../../../config/heroku_targets.yml", __FILE__))
    end

    protected

    def deploy_message(target, deploy_ref_describe)
      downtime = options[:migrate] ? "less than a minute" : "a few seconds"
      message = <<-DEPLOY_MESSAGE
    Deploying #{deploy_ref_describe}.
    #{target.display_name} will be down for #{downtime} (in less than a minute from now).
      DEPLOY_MESSAGE
      message = message.gsub(/(\s|\n)+/, " ")
    end

    def puts_and_system(cmd)
      puts cmd
      puts "-------------"
      system_with_clean_env cmd
      puts "-------------"
    end

    def puts_and_exec(cmd)
      puts cmd
      exec_with_clean_env(cmd)
    end

    def system_with_clean_env(cmd)
      if defined?(Bundler)
        Bundler.with_clean_env { system cmd }
      else
        system cmd
      end
    end

    def exec_with_clean_env(cmd)
      if defined?(Bundler)
        Bundler.with_clean_env { `#{cmd}` }
      else
        `#{cmd}`
      end
    end

    def maintenance_on(target)
      puts_and_system "heroku maintenance:on -a #{target.heroku_app}"
      puts_and_system "heroku config:set MAINTENANCE_MODE=true -a #{target.heroku_app}"
    end

    def maintenance_off(target)
      puts_and_system "heroku maintenance:off -a #{target.heroku_app}"
      puts_and_system "heroku config:unset MAINTENANCE_MODE -a #{target.heroku_app}"
    end
  end

  include Shared

  class_option :verbose, type: :boolean, aliases: "v", default: true
  default_command :help

  desc "deploy TARGET (REF)", "deploy the latest to TARGET (optionally give a REF like a tag to deploy)"
  method_option :migrate, default: true, desc: "Run with migrations", type: :boolean
  method_option :maintenance, default: nil, desc: "Run with migrations", type: :boolean

  def deploy(target_name, deploy_ref = nil)
    target = lookup_heroku(target_name)
    deploy_ref = check_deploy_ref(deploy_ref, target)
    deploy_ref_description = deploy_ref_describe(deploy_ref)
    maintenance = options[:maintenance].nil? && options[:migrate] || options[:maintenance]
    puts "Deploy #{deploy_ref_description} to #{target} with migrate=#{options[:migrate]} maintenance=#{maintenance} "

    invoke :list_deployed, [target_name, deploy_ref], {}
    message = deploy_message(target, deploy_ref_description)
    set_message(target_name, message)
    puts_and_system "git push -f #{target.git_remote} #{deploy_ref}:master"

    maintenance_on(target) if maintenance
    puts_and_system "heroku run rake db:migrate -a #{target.heroku_app}" if options[:migrate]

    puts_and_system %{heroku config:set COMMIT_HASH=$(git log -1 --pretty=format:"%h" #{deploy_ref}) -a #{target.heroku_app}}
    if maintenance
      maintenance_off(target)
    else
      puts_and_system "heroku restart -a #{target.heroku_app}"
    end
    set_message(target_name, nil)
    deploy_tracking(target_name, deploy_ref)
  end

  desc "maintenance ON|OFF", "turn maintenance mode on or off"
  method_option :target_name, aliases: "a", desc: "Target (app or remote)"

  def maintenance(on_or_off)
    target = lookup_heroku(options[:target_name])
    case on_or_off.upcase
    when "ON"
      maintenance_on(target)
    when "OFF"
      maintenance_off(target)
    else
      raise Thor::Error, "maintenance must be ON or OFF not #{on_or_off}"
    end
  end

  desc "set_urls TARGET", "set and cache the error and maintenance page urls for TARGET"

  def set_urls(target_name)
    target = lookup_heroku(target_name)
    asset_host = get_config_env(target, "ASSET_HOST")
    time = Time.now.strftime("%Y%m%d-%H%M-%S")
    url_hash = {
      ERROR_PAGE_URL: "https://#{asset_host}/platform_error/#{time}",
      MAINTENANCE_PAGE_URL: "https://#{asset_host}/platform_maintenance/#{time}"
    }
    url_hash.each do |_env, url|
      puts_and_system "open #{url}"
    end
    puts_and_system(
      "heroku config:set #{url_hash.map { |e, u| "#{e}=#{u}" }.join(' ')} -a #{target.heroku_app}"
    )
  end

  no_commands do
    def get_config_env(target, env_var)
      puts_and_exec("heroku config:get #{env_var} -a #{target.heroku_app}").strip.presence
    end

    def deploy_ref_describe(deploy_ref)
      `git describe #{deploy_ref}`.strip
    end
  end
  desc "deploy_tracking TARGET (REF)", "set deploy tracking for TARGET and REF (used by deploy)"

  def deploy_tracking(target_name, deploy_ref = nil)
    target = lookup_heroku(target_name)
    deploy_ref = check_deploy_ref(deploy_ref, target)
    release_stage = target.staging? ? "staging" : "production"
    revision = `git log -1 #{deploy_ref} --pretty=format:%H`
    api_key = ENV["BUGSNAG_API_KEY"]
    data = %W(
      apiKey=#{api_key}
      releaseStage=#{release_stage}
      repository=#{target.repository}
      revision=#{revision}
      appVersion=#{deploy_ref_describe(deploy_ref)}
    ).join("&")
    command = "curl -d #{data} http://notify.bugsnag.com/deploy"
    if api_key.blank?
      puts "\n" + ("*" * 80) + "\n"
      puts command
      puts "\n" + ("*" * 80) + "\n"
      puts "NB: can't notify unless you specify BUGSNAG_API_KEY and rerun"
      puts "  thor heroku:deploy_tracking #{target_name} #{deploy_ref}"
    else
      puts_and_system "curl -d \"#{data}\" http://notify.bugsnag.com/deploy"
    end
  end

  desc "set_message TARGET (MESSAGE)", "sets a MESSAGE to display on the TARGET server,
providing the server supports the set_message task. If you give no MESSAGE, it will clear the message"

  def set_message(target_name, message = nil)
    # not supported at present. need a data:util:set_message task
    # target = lookup_heroku(target_name)
    # if message
    #   puts_and_system "heroku run rake data:util:set_message[\"'#{message}'\"] -a #{target.heroku_app}"
    # else
    #   puts_and_system "heroku run rake data:util:set_message -a #{target.heroku_app}"
    # end
  end

  desc "list_deployed TARGET (DEPLOY_REF)", "list what would be deployed to TARGET (optionally specify deploy_ref)"

  def list_deployed(target_name, deploy_ref = nil)
    target = lookup_heroku(target_name)
    deploy_ref = check_deploy_ref(deploy_ref, target)
    deploy_ref_description = deploy_ref_describe(deploy_ref)
    puts "------------------------------"
    puts " Deploy to #{target}:"
    puts "------------------------------"
    system_with_clean_env "git --no-pager log $(heroku config:get COMMIT_HASH -a #{target.heroku_app})..#{deploy_ref}"
    puts "------------------------------"
  end

  desc "about (TARGET)", "Describe available targets or one specific target"

  def about(target_name = nil)
    if target_name.nil?
      puts "Targets: "
      heroku_targets.targets.each_pair do |key, target|
        puts " * #{key} (#{target})"
      end
    else
      target = lookup_heroku(target_name)
      puts "Target #{target_name}:"
      puts " * display_name: #{target.display_name}"
      puts " * heroku_app:   #{target.heroku_app}"
      puts " * git_remote:   #{target.git_remote}"
      puts " * deploy_ref:   #{target.deploy_ref}"
    end
    puts
    puts "(defined in config/heroku_targets.yml)"
  end

  class Sync < Thor
    include Shared
    class_option :from, type: :string, desc: "source target (production, staging...)", required: true, aliases: "f"

    desc "down --from SOURCE_TARGET", "syncs db down from SOURCE_TARGET | thor heroku:sync -f production"

    def down
      invoke "warn", [], from: options[:from]
      invoke "grab", [], from: options[:from]
      invoke "from_dump", [], from: options[:from]
    end

    desc "warn", "warn", hide: true

    def warn
      puts "should maybe 'rake db:drop_all_tables' first"
      puts "if you have done some table-creating migrations that need tobe undone???"
    end

    desc "grab --from SOURCE_TARGET", "capture and download dump from SOURCE_TARGET", hide: true

    def grab
      source = lookup_heroku(options[:from])
      capture_cmd = "heroku pg:backups:capture -a #{source.heroku_app}"
      puts_and_system capture_cmd
      invoke "download", [], from: options[:from]
    end

    desc "download --from SOURCE_TARGET", "download latest db snapshot on source_target"

    def download
      source = lookup_heroku(options[:from])
      download_cmd = "curl -o #{source.dump_filename} `heroku pg:backups:public-url -a #{source.heroku_app}`"
      puts_and_system download_cmd
    end

    desc "from_dump --from SOURCE_TARGET", "make the db the same as the last target dump from SOURCE_TARGET"

    def from_dump
      invoke "warn", [], from: options[:from]
      source = lookup_heroku(options[:from])
      rails_env = ENV["RAILS_ENV"] || "development"
      db_config = DbConfiguration.config[rails_env]
      db_username = \
        if (username = db_config["username"])
          "-U #{username}"
        else
          ""
        end
      db = db_config["database"]
      system_with_clean_env "pg_restore --verbose --clean --no-acl --no-owner -h localhost #{db_username} -d #{db} #{source.dump_filename}"
      system_with_clean_env "rake db:migrate"
      system_with_clean_env "rake dev:dev_data"
      system_with_clean_env "rake db:test:prepare"
    end

    desc "to STAGING_TARGET --from=SOURCE_TARGET", "push db onto STAGING_TARGET from SOURCE_TARGET"

    def to(to_target_name)
      target = lookup_heroku_staging(to_target_name)
      source = lookup_heroku(options[:from])

      maintenance_on(target)

      puts_and_system %(
        heroku pg:copy #{source.heroku_app}::#{source.db_color} #{target.db_color} -a #{target.heroku_app} --confirm #{target.heroku_app}
      )
      puts_and_system %(
                heroku run rake db:migrate -a #{target.heroku_app}
          )

      Db.new.anonymize(to_target_name)

      puts_and_system %(
                heroku restart -a #{target.heroku_app}
          )
      maintenance_off(target)
    end
  end

  class Db < Thor
    include Shared

    desc "drop_all_tables on STAGING_TARGET", "drop all tables on STAGING_TARGET"

    def drop_all_tables(staging_target_name)
      target = lookup_heroku_staging(staging_target_name)
      generate_drop_tables_sql = `#{DbConfiguration.generate_drop_tables_sql}`
      cmd_string = %(heroku pg:psql -a #{target.heroku_app} -c "#{generate_drop_tables_sql}")
      puts_and_system(cmd_string)
    end

    desc "anonymize STAGING_TARGET", "run anonymization scripts on STAGING_TARGET"

    def anonymize(staging_target_name)
      target = lookup_heroku_staging(staging_target_name)
      puts_and_system %(
        heroku run rake data:anonymize -a #{target.heroku_app}
          )
    end
  end

end
