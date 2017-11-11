module Postable
  extend ActiveSupport::Concern

  included do
    has_many :posts,            foreign_key: :author_id, class_name: "Post",        dependent: :destroy
    has_many :replies,          foreign_key: :author_id, class_name: "Reply",       dependent: :destroy
    has_many :chat_messages,    foreign_key: :author_id, class_name: "ChatMessage", dependent: :destroy
    has_many :post_edits,       foreign_key: :edited_by_id
    has_many :post_views,       foreign_key: :viewed_by_id
    has_many :votes, class_name: "UserPollVote",                                    dependent: :destroy
    has_many :favorite_replies,                                                     dependent: :destroy
    # has_many :user_tags

    has_many :invites_sent, foreign_key: :from_user_id,    class_name: "Invite",    dependent: :destroy
    has_many :invites,      foreign_key: :invited_user_id, class_name: "Invite",    dependent: :destroy
    has_many :tags_from_posts,   -> { distinct }, through: :posts,   source: :tags
    has_many :tags_from_replies, -> { distinct }, through: :replies, source: :tags
    # has_many :tags,             through: :user_tags
    has_many :notices,       dependent: :destroy
    has_many :subscriptions, dependent: :destroy

    scope :by_tags, ->(*tag_words) { where(id: Tag.by_words(tag_words).map(&:user_ids).inject(&:&)) }
  end

  def can_view?(postable)
    return true unless postable.marked_as_adult?
    return true if adult?
    self == postable.author
  end

  def can_edit_posts?
    long_time_user? || mod?
  end

  def favorite_reply_for_post(post)
    favorite_replies.find_by(post: post)
  end

  def reciprocity(since=4.days.ago)
    since = [since, 4.days.ago].max
    recent_replies = replies.where("replies.created_at > ?", since)
    replies_for_posts_not_belonging_to_user = recent_replies.joins(:post).where.not(posts: { author_id: self.id })
    uniq_posts_for_replies = replies_for_posts_not_belonging_to_user.pluck(:post_id, :author_id).uniq
    uniq_posts_for_replies.count
  end

  def activity(day_count)
    activity_hash = {}
    day_count.times do |t|
      date = t.days.ago
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
