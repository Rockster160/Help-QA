module Friendable
  extend ActiveSupport::Concern

  included do
    has_many :shouts,        foreign_key: :sent_to_id,   class_name: "Shout",      dependent: :destroy
    has_many :shouts_to,     foreign_key: :sent_to_id,   class_name: "Shout",      dependent: :destroy
    has_many :shouts_from,   foreign_key: :sent_from_id, class_name: "Shout",      dependent: :destroy
    has_many :friends_added, foreign_key: :user_id,      class_name: "Friendship", dependent: :destroy
    has_many :added_by,      foreign_key: :friend_id,    class_name: "Friendship", dependent: :destroy
  end

  def recent_shouts
    @_recent_shouts ||= shouts_to.where("created_at > ?", 30.days.ago)
  end

  def friendships
    Friendship.where("user_id = :user_id OR friend_id = :user_id", user_id: self.id)
  end
  def friends?(friend)
    friends.pluck(:id).include?(friend.id)
  end
  def added?(friend)
    friends_added.where(friend_id: friend.id).any?
  end
  def added_by?(friend)
    added_by.where(user_id: friend.id).any?
  end

  def shared_email?(friend)
    false
  end

  def favorites
    @_favorites ||= User.not_banned.joins(:added_by).where.not(users: { id: id }, friendships: { friend_id: friends.ids }).distinct
  end
  def fans
    @_fans ||= User.not_banned.joins(:friends_added).where.not(users: { id: id }, friendships: { user_id: friends.ids }).distinct
  end
  def friends
    @_friends ||= begin
      User.not_banned.where(id: (friends_added.pluck(:friend_id) & added_by.pluck(:user_id)).uniq)
    end
  end
  def not_friends
    @_not_friends ||= User.where.not(id: friends.pluck(:id))
  end

  def reset_friends_cache
    @_favorites = nil
    @_fans = nil
    @_friends = nil
    @_not_friends = nil
  end

  def add_friend(friend)
    friends_added.find_or_create_by(friend_id: friend.id) do
      if added_by?(friend)
        friend_path = Rails.application.routes.url_helpers.user_path(self)
        ActionCable.server.broadcast("notifications_#{friend.id}", message: "<a href=\"#{friend_path}\">#{self.username}</a> has accepted your friend request!")
      else
        friend.notices.friend_request.create(friend: self)
      end
    end
    reset_friends_cache
  end
  def remove_friend(friend)
    friends_added.find_by(friend_id: friend.id).destroy
    reset_friends_cache
  end

end
