class AddMorePermissionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_developer, :boolean, default: false
    add_column :users, :edits_master_text, :boolean, default: false
  end
end
