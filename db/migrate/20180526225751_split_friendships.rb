class SplitFriendships < ActiveRecord::Migration[5.0]
  def change
    Friendship.where.not(accepted_at: nil).each do |friendship|
      Friendship.find_or_create_by(user_id: friendship.friend_id, friend_id: friendship.user_id)
    end

    add_column :friendships, :shared_email_at, :datetime
    remove_column :friendships, :accepted_at, :datetime
  end
end
