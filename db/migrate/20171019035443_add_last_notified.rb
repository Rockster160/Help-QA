class AddLastNotified < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :last_notified_at, :datetime
  end
end
