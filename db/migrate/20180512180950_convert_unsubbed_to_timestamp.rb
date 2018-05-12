class ConvertUnsubbedToTimestamp < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :unsubscribed_at, :datetime
    Subscription.where(unsubscribed: true).find_each do |s|
      s.update(unsubscribed_at: s.created_at)
    end
    remove_column :subscriptions, :unsubscribed, :boolean
  end
end
