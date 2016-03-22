class AddSendAdministratorEmailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_administrator_emails, :boolean
  end
end
