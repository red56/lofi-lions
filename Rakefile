# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

LofiLions::Application.load_tasks

begin
  spec = Gem::Specification.find_by_name "heroku_tool"
  load File.expand_path("lib/heroku_tool/tasks/db_drop_all_tables.rake", spec.gem_dir)
rescue LoadError
  # not loading db_drop_all_tables -- not defined in this environment?
end
