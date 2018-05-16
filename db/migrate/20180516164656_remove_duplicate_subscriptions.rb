class RemoveDuplicateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    Subscription.order("unsubscribed_at NULLS LAST").find_each do |subscription|
      subscription.destroy if Subscription.where.not(id: subscription.id).where(post_id: subscription.post_id, user_id: subscription.user_id).any?
    end

    add_index :subscriptions, [:post_id, :user_id], unique: true
  end
end
