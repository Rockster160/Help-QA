module Friendable
  extend ActiveSupport::Concern

  included do
    has_many :shouts,           foreign_key: :sent_to_id,      class_name: "Shout"
    has_many :shouts_to,        foreign_key: :sent_to_id,      class_name: "Shout"
    has_many :shouts_from,      foreign_key: :sent_from_id,    class_name: "Shout"
    has_many :requested_friendships, class_name: "Friendship", foreign_key: "user_id"
    has_many :pending_friendships, class_name: "Friendship", foreign_key: "friend_id"
  end

  def recent_shouts
    shouts_to.where("created_at > ?", 30.days.ago)
  end

  def friendships
    Friendship.where("user_id = :user_id OR friend_id = :user_id", user_id: self.id)
  end
  def friendship_with(friend)
    Friendship.where("(friendships.user_id = :user_id AND friendships.friend_id = :friend_id) OR (friendships.user_id = :friend_id AND friendships.friend_id = :user_id)", user_id: self.id, friend_id: friend.id).first
  end
  def friends?(friend)
    friendship_with(friend).try(:friends?)
  end
  def added?(friend)
    friends?(friend) || favorites.pluck(:id).include?(friend.id)
  end
  def added_by?(friend)
    friends?(friend) || fans.pluck(:id).include?(friend.id)
  end

  def favorites
    User.joins(:pending_friendships).where(friendships: { user_id: self.id, accepted_at: nil })
  end
  def fans
    User.joins(:requested_friendships).where(friendships: { friend_id: self.id, accepted_at: nil })
  end
  def friends
    favorite_ids = User.joins(:pending_friendships).where(friendships: { user_id: self.id }).where.not(friendships: { accepted_at: nil }).pluck(:id)
    fan_ids = User.joins(:requested_friendships).where(friendships: { friend_id: self.id }).where.not(friendships: { accepted_at: nil }).pluck(:id)
    User.where(id: (favorite_ids + fan_ids).uniq)
  end

  def add_friend(friend)
    existing_friendship = friendship_with(friend)

    if existing_friendship.try(:friend_id) == self.id # They requested to be my friend already, so I can accept the request.
      existing_friendship.update(accepted_at: DateTime.current)
    elsif existing_friendship.nil?
      friendships.create(user_id: self.id, friend_id: friend.id)
    end
  end
  def remove_friend(friend)
    existing_friendship = friendship_with(friend)
    return unless existing_friendship.present?
    request_at = existing_friendship.created_at
    accepted_at = existing_friendship.accepted_at

    if existing_friendship.user_id == self.id # I was the initial requester
      existing_friendship.destroy
      new_friendship = friend.add_friend(self)
      new_friendship.update(created_at: accepted_at)
    elsif existing_friendship.friend_id == self.id # They made the request first
      existing_friendship.update(accepted_at: nil)
    end
  end

end
