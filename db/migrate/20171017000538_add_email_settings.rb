class AddEmailSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :user_settings, :last_email_sent, :datetime
    add_column :user_settings, :send_email_notifications, :boolean, default: true
  end
end
