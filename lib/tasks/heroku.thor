require File.expand_path('../../heroku_targets', __FILE__)
require File.expand_path('../../../lib/db_configuration', __FILE__)
require File.expand_path('../../../config/initializers/00-version', __FILE__)
class Heroku < Thor

  module Shared

    def self.exit_on_failure?
      true
    end

    def lookup_heroku_staging(staging_target_name)
      heroku_targets.staging_targets[staging_target_name] or raise Thor::Error.new(missing_target_error(staging_target_name,
          true))
    end

    def lookup_heroku(target_name)
      heroku_targets.targets[target_name] or raise Thor::Error.new(missing_target_error(target_name, false))
    end

    def missing_target_error(target_name, staging)
      if staging
        description = "Staging target_name '#{target_name}'"
        targets = heroku_targets.staging_targets.keys
      else
        description = "Target '#{target_name}'"
        targets = heroku_targets.targets.keys
      end
      "#{description} was not found. Valid targets are #{targets.collect { |t| "'#{t}'" }.join(',')}"
    end

    def heroku_targets
      @heroku_targets ||= HerokuTargets.from_file(File.expand_path('../../../config/heroku_targets.yml', __FILE__))
    end

    protected

    def deploy_message(target, deploy_ref_describe)
      downtime = options[:migrate] ? "less than a minute" : "a few seconds"
      message = <<-DEPLOY_MESSAGE
    Deploying #{deploy_ref_describe}.
    #{target.display_name} will be down for #{downtime} (in less than a minute from now).
      DEPLOY_MESSAGE
      message = message.gsub(/(\s|\n)+/, ' ')
    end

    def puts_and_system cmd
      puts cmd
      puts "-------------"
      system_with_clean_env cmd
      puts "-------------"
    end

    def system_with_clean_env cmd
      if defined?(Bundler)
        Bundler.with_clean_env { system cmd }
      else
        system cmd
      end
    end
  end

  include Shared

  class_option :verbose, :type => :boolean, aliases: 'v', default: true
  default_command :help

  desc "deploy TARGET (REF)", "deploy the latest to TARGET (optionally give a REF like a tag to deploy)"
  method_option :migrate, type: :boolean, default: true, desc: "Run with migrations"

  def deploy(target_name, deploy_ref=nil)
    target = lookup_heroku(target_name)
    deploy_ref ||= target.deploy_ref
    deploy_ref_description = deploy_ref_describe(deploy_ref)
    puts "Deploy #{deploy_ref_description} to #{target} with migrate=#{options[:migrate]} "

    invoke :list_deployed, [target_name, deploy_ref], {}
    message = deploy_message(target, deploy_ref_description)
    set_message(target_name, message)
    puts_and_system "git push -f #{target.git_remote} #{deploy_ref}:master"
    if options[:migrate]
      puts_and_system "heroku maintenance:on --app=#{target.heroku_app}"
      puts_and_system "heroku run rake db:migrate --app=#{target.heroku_app}"
    end
    puts_and_system %{heroku config:add COMMIT_HASH=$(git log -1 --pretty=format:"%h" #{deploy_ref}) --app=#{target.heroku_app}}
    puts_and_system "heroku restart --app=#{target.heroku_app}"
    if options[:migrate]
      puts_and_system "heroku maintenance:off --app=#{target.heroku_app}"
    end
    set_message(target_name, nil)
    deploy_tracking(target_name, deploy_ref)
  end

  no_commands {
    def deploy_ref_describe(deploy_ref)
      `git describe #{deploy_ref}`.strip
    end
  }
  desc "deploy_tracking TARGET (REF)", "set deploy tracking for TARGET and REF (used by deploy)"

  def deploy_tracking(target_name, deploy_ref=nil)
    target = lookup_heroku(target_name)
    deploy_ref ||= target.deploy_ref
    releaseStage = target.staging? ? 'staging' : 'production'
    revision = `git log -1 #{deploy_ref} --pretty=format:%H`
    apiKey = ENV['BUGSNAG_API_KEY']
    data = %W(
      apiKey=#{apiKey}
      releaseStage=#{releaseStage}
      repository=https://github.com/fieldnotescommunities/fieldnotes-webapp
      revision=#{revision}
      appVersion=#{deploy_ref_describe(deploy_ref)}
    ).join('&')
    command = "curl -d #{data} http://notify.bugsnag.com/deploy"
    if apiKey.blank?
      puts "\n"+("*" *80)+"\n"
      puts command
      puts "\n"+("*" *80)+"\n"
      puts "NB: can't notify unless you specify BUGSNAG_API_KEY and rerun"
      puts "  thor heroku:deploy_tracking #{target_name} #{deploy_ref}"
    else
      puts_and_system "curl -d \"#{data}\" http://notify.bugsnag.com/deploy"
    end
  end

  desc "set_message TARGET (MESSAGE)", "sets a MESSAGE to display on the TARGET server,
providing the server supports the set_message task. If you give no MESSAGE, it will clear the message"

  def set_message(target_name, message=nil)
    # target = lookup_heroku(target_name)
    # if message
    #   puts_and_system "heroku run rake data:util:set_message[\"'#{message}'\"] --app=#{target.heroku_app}"
    # else
    #   puts_and_system "heroku run rake data:util:set_message --app=#{target.heroku_app}"
    # end
  end

  desc "list_deployed TARGET (DEPLOY_REF)", "list what would be deployed to TARGET (optionally specify deploy_ref)"

  def list_deployed(target_name, deploy_ref=nil)
    target = lookup_heroku(target_name)
    deploy_ref ||= target.deploy_ref
    deploy_ref_description = deploy_ref_describe(deploy_ref)
    puts "------------------------------"
    puts " Deploy to #{target}:"
    puts "------------------------------"
    system_with_clean_env "git --no-pager log $(heroku config:get COMMIT_HASH --app=#{target.heroku_app})..#{deploy_ref}"
    puts "------------------------------"
  end

  desc "about (TARGET)", "Describe available targets or one specific target"

  def about(target_name=nil)
    if target_name.nil?
      puts "Targets: "
      heroku_targets.targets.each_key do |key, target|
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
    class_option :from, type: :string, desc: "source target (production, staging...)", required: true, aliases: 'f'

    desc 'down --from SOURCE_TARGET', 'syncs db down from SOURCE_TARGET | thor heroku:sync -f production'

    def down
      invoke 'grab', [], {from: options[:from]}
      invoke 'from_dump', [], {from: options[:from]}
    end

    desc 'warn', 'warn', hide: true

    def warn
      puts "should maybe 'rake db:drop_all_tables' first"
      puts "if you have done some table-creating migrations that need tobe undone???"
    end

    desc 'grab --from SOURCE_TARGET', 'capture and download dump from SOURCE_TARGET', hide: true

    def grab
      invoke 'warn', [], {from: options[:from]}
      source = lookup_heroku(options[:from])
      # Capture and pull db snapshot
      capture_cmd = "heroku pg:backups capture --expire --app=#{source.heroku_app}"
      retrieve_cmd = "curl -o #{source.dump_filename} `heroku pg:backups public-url --app=#{source.heroku_app}`"
      system_with_clean_env capture_cmd
      system_with_clean_env retrieve_cmd
    end

    desc 'from_dump --from SOURCE_TARGET', 'make the db the same as the last target dump from SOURCE_TARGET'

    def from_dump
      invoke 'warn', [], {from: options[:from]}
      source = lookup_heroku(options[:from])
      rails_env = ENV['RAILS_ENV'] || 'development'
      db_config = DbConfiguration.config[rails_env]
      db_username = db_config["username"]
      db_username_flag = db_username.blank? ? "" : "-U #{db_username}"
      db = db_config["database"]
      system_with_clean_env "pg_restore --verbose --clean --no-acl --no-owner -h localhost #{db_username_flag} -d #{db} #{source.dump_filename}"
      system_with_clean_env "rake db:migrate"
      system_with_clean_env "rake dev:dev_users"
      system_with_clean_env "rake db:test:prepare"
    end

    desc "to STAGING_TARGET --from=SOURCE_TARGET", "push db onto STAGING_TARGET from SOURCE_TARGET"

    def to(to_target_name)
      target = lookup_heroku_staging(to_target_name)
      source = lookup_heroku(options[:from])

      invoke :warn, [], {from: options[:from]}

      puts_and_system %Q{
                heroku pg:backups capture --expire --app=#{source.heroku_app} &&
                heroku pg:backups restore DATABASE `heroku pgbackups:url --app=#{source.heroku_app}` --app=#{target
              .heroku_app} --confirm #{target.heroku_app}
      }
      puts_and_system %Q{
                heroku run rake db:migrate --app=#{target.heroku_app}
      }

      Db.new.anonymize(to_target_name)

      puts_and_system %Q{
                heroku restart --app=#{target.heroku_app}
      }
    end
  end

  class Db < Thor
    include Shared

    desc "drop_all_tables on STAGING_TARGET", "drop all tables on STAGING_TARGET"

    def drop_all_tables(staging_target_name)
      target = lookup_heroku_staging(staging_target_name)
      generate_drop_tables_sql = `#{DbConfiguration.generate_drop_tables_sql}`
      cmd_string = %{heroku pg:psql --app=#{target.heroku_app} -c "#{generate_drop_tables_sql}"}
      puts_and_system(cmd_string)
    end

  end


end
