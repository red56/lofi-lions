# frozen_string_literal: true

require "thor"
spec = Gem::Specification.find_by_name "heroku_tool"
Thor::Util.load_thorfile(File.expand_path("lib/heroku_tool/tasks/heroku.thor", spec.gem_dir))

class Heroku
  module MyConfig
    def maintenance_mode_env_var
      "MAINTENANCE_MODE"
    end

    def app_revision_env_var
      "COMMIT_HASH"
    end

    def after_sync_down(instance)
      super
      instance.puts_and_system "rake dev:dev_data"
    end
    #
    # def after_sync_to(instance, target)
    #  super
    #  instance.puts_and_system %(heroku run rake dev:staging_data -a #{target.heroku_app})
    # end
    #
    # def before_deploying(instance, target, version)
    #   # override
    # end
    #
    # def after_deploying(instance, target, version)
    #   # override
    # end
  end

  module Configuration
    class << self
      prepend MyConfig
    end
  end

  # desc "set_message TARGET (MESSAGE)", "sets a MESSAGE to display on the TARGET server. If you give no MESSAGE, it will clear the message"
  #
  # def set_message(target_name, message = nil)
  #   target = lookup_heroku(target_name)
  #   if message
  #     puts_and_system "heroku run rake data:util:set_message[\"#{message}\"] -a #{target.heroku_app}"
  #   else
  #     puts_and_system "heroku run rake data:util:set_message -a #{target.heroku_app}"
  #   end
  # end
end
