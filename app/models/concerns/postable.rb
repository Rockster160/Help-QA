module Postable
  extend ActiveSupport::Concern

  included do
    has_many :posts,            foreign_key: :author_id
    has_many :replies,          foreign_key: :author_id
    has_many :post_edits,       foreign_key: :edited_by_id
    has_many :post_views,       foreign_key: :viewed_by_id
    has_many :votes, class_name: "UserPollVote"
    has_many :favorite_replies
    # has_many :user_tags

    has_many :invites_sent, foreign_key: :from_user_id,    class_name: "Invite"
    has_many :invites,      foreign_key: :invited_user_id, class_name: "Invite"
    has_many :tags_from_posts,   -> { distinct }, through: :posts,   source: :tags
    has_many :tags_from_replies, -> { distinct }, through: :replies, source: :tags
    # has_many :tags,             through: :user_tags
    has_many :notices
    has_many :subscriptions
  end

  def can_view?(postable)
    return true unless postable.marked_as_adult?
    return true if adult?
    self == postable.author
  end

  def favorite_reply_for_post(post)
    favorite_replies.find_by(post: post)
  end

  def activity(day_count)
    activity_hash = {}
    day_count.times do |t|
      date = (t + 1).days.ago
      posts_on_date = posts.where(created_at: date.beginning_of_day..date.end_of_day)
      replies_on_date = replies.where(created_at: date.beginning_of_day..date.end_of_day)
      activity_hash[date.to_date.to_s] = {posts: posts_on_date.length, replies: replies_on_date.length}
    end
    activity_hash
  end

  def letter
    return "?" unless username.present?
    (username.gsub(/[^a-z]/i, "").first.presence || "?").upcase
  end

end
