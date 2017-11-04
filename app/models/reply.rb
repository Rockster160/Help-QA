# == Schema Information
#
# Table name: replies
#
#  id                    :integer          not null, primary key
#  body                  :text
#  author_id             :integer
#  posted_anonymously    :boolean
#  has_questionable_text :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  post_id               :integer
#  removed_at            :datetime
#  marked_as_adult       :boolean
#  favorite_count        :integer          default("0")
#

class Reply < ApplicationRecord
  include Anonicon
  include MarkdownHelper

  belongs_to :post, counter_cache: :reply_count
  belongs_to :author, class_name: "User"
  has_many :tags, through: :post
  has_many :favorite_replies
  has_many :favorited_by, through: :favorite_replies, source: :user

  before_validation :format_body

  validate :post_is_open, :debounce_replies, :valid_text

  after_create :invite_users, :notify_subscribers
  after_update :read_questionable_text

  after_commit :broadcast_creation

  scope :claimed,           -> { where.not(posted_anonymously: true) }
  scope :unclaimed,         -> { where(posted_anonymously: true) }
  scope :not_removed,       -> { where(removed_at: nil) }
  scope :not_banned,        -> { joins(:author).where("users.banned_until IS NULL OR users.banned_until < ?", DateTime.current) }
  scope :favorited,         -> { where("favorite_count > 0") }
  scope :removed,           -> { where.not(removed_at: nil) }
  scope :adult,             -> { where(marked_as_adult: true) }
  scope :safe,              -> { where(marked_as_adult: [nil, false]) }
  scope :questionable,      -> { where(has_questionable_text: true) }
  scope :verified_by_mod,   -> { where(has_questionable_text: [nil, false]) }
  scope :without_adult,     -> { where(replies: { marked_as_adult: [nil, false] }) }
  scope :conditional_adult, ->(user) { verified_by_mod.without_adult unless user.try(:adult?) && !user.try(:settings).try(:hide_adult_posts?) }

  def safe?; !marked_as_adult?; end
  def removed?; removed_at?; end

  def username
    if posted_anonymously?
      "Anonymous"
    else
      author.username
    end
  end

  def avatar(size: nil)
    if posted_anonymously?
      anonicon_src(author.ip_address)
    else
      author.avatar(size: size)
    end
  end

  def letter
    author.try(:letter) || "?"
  end

  def location
    return unless author.try(:location)
    [author.location.city.presence, author.location.region_code.presence, author.location.country_code.presence].compact.join(", ")
  end

  def same_author_as_post?
    author_id == post.author_id && posted_anonymously? == post.posted_anonymously?
  end

  private

  def broadcast_creation
    ActionCable.server.broadcast("replies_for_#{post_id}", {})
  end

  def post_is_open
    return if post.open?

    errors.add(:base, "We're very sorry- but this post has been closed.")
  end

  def debounce_replies
    return if author.replies.where("created_at > ?", 5.seconds.ago).none?

    errors.add(:base, "Slow down there! You're posting too fast. You can only reply once every 5 seconds.")
  end

  def valid_text
    if body.squish == "Post a reply"
      errors.add(:base, "Try adding some text first!")
    end
    if body.length <= 1
      errors.add(:base, "Try adding some more text! This isn't long enough.")
    end
  end

  def notify_subscribers
    subscription = Subscription.find_or_create_by(user_id: author_id, post_id: post_id)
    post.notify_subscribers(not_user: author)

    if has_questionable_text?
      User.mod.each do |mod|
        mod.notices.questionable_reply.create(notice_for_id: self.id)
      end
    end
  end

  def invite_users
    return if posted_anonymously?
    invited_friends = []
    body.scan(/@([^ \`\@]+)/) do |username_tag|
      friend = author.friends.by_username($1)
      invite = friend.invites.create(post: post, reply: self, from_user: author) if friend && invited_friends.exclude?(friend.id)
      invited_friends << friend.try(:id)
    end
  end

  def format_body
    self.body = filter_nested_quotes(body, max_nest_level: 4)
    if new_record? && !author.long_term_user?
      self.has_questionable_text = Tag.adult_words_in_body(body).any?
    end
  end

  def read_questionable_text
    Notice.questionable_reply.where(notice_for_id: self.id).each(&:read)
  end

  def anonicon_src(ip)
    Anonicon.generate(ip)
  end
end
