class AddLastNotifiedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_notified, :datetime

    User.update_all(last_notified: Time.current)
  end
end
