class AddMoreSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :user_settings, :send_reply_notifications, :boolean, default: true
    add_column :user_settings, :default_anonymous, :boolean, default: false
    add_column :user_settings, :friends_only, :boolean, default: false
    add_column :users, :completed_signup, :boolean, default: false
  end
end
