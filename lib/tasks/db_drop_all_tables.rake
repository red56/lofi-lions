require Rails.root.join('lib/db_configuration')

namespace :db do

  desc "drop all tables without worrying about concurrent accesses"
  task :drop_all_tables => :environment do
    abort("Don't run this on production") if Rails.env.production?
    db_config = DbConfiguration.config[Rails.env]
    user = db_config['username']
    db = db_config['database']
    cmd_string = %{psql -U #{user} #{db} -t -c "select 'drop table \\"' || tablename || '\\" cascade;' from pg_tables where schemaname = 'public'" | psql -U #{user} #{db}}
    puts cmd_string
    system(cmd_string)
  end

end