class AddIsAdministratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_administrator, :boolean, default: false, null: false
  end
end
