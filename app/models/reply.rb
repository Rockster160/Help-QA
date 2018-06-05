# == Schema Information
#
# Table name: replies
#
#  id                 :integer          not null, primary key
#  body               :text
#  author_id          :integer
#  posted_anonymously :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  post_id            :integer
#  removed_at         :datetime
#  marked_as_adult    :boolean
#  favorite_count     :integer          default("0")
#  in_moderation      :boolean          default("false")
#

class Reply < ApplicationRecord
  include MarkdownHelper
  include Sherlockable
  include UrlHelper
  attr_accessor :hide_update, :has_invited

  sherlockable klass: :reply, ignore: [ :created_at, :updated_at, :favorite_count ]

  belongs_to :post, counter_cache: :reply_count
  belongs_to :author, class_name: "User"
  has_many :tags, through: :post
  has_many :invites
  has_many :favorite_replies
  has_many :favorited_by, through: :favorite_replies, source: :user

  before_validation :format_body

  validate :post_is_open, :debounce_replies, :valid_text

  after_create :notify_subscribers

  before_save :invite_users
  after_commit :broadcast_creation, :update_popular_post

  scope :by_fuzzy_text,        ->(text) { where("replies.body ILIKE ?", "%#{text.gsub(/['"’“”]/, "['\"’“”]")}%") }
  scope :regex_search,         ->(text) { where("replies.body ~* ?", text.gsub(/['"’“”]/, "['\"’“”]")) }
  scope :claimed,              -> { where(posted_anonymously: [false, nil]) }
  scope :unclaimed,            -> { where(posted_anonymously: true) }
  scope :not_banned,           -> { joins(:author).where("users.banned_until IS NULL OR users.banned_until < ?", DateTime.current) }
  scope :favorited,            -> { where("favorite_count > 0") }
  scope :removed,              -> { where.not(removed_at: nil) }
  scope :not_removed,          -> { joins(:post).where(posts: { removed_at: nil }, replies: { removed_at: nil }) }
  scope :adult,                -> { where(marked_as_adult: true) }
  scope :child_safe,           -> { where(marked_as_adult: [nil, false]) }
  scope :needs_moderation,     -> { where(in_moderation: true) }
  scope :no_moderation,        -> { where(in_moderation: [nil, false]) }
  scope :without_adult,        -> { where(replies: { marked_as_adult: [nil, false] }) }
  scope :not_helpbot,          -> { joins(:author).where.not("users.username = 'HelpBot'") }
  scope :conditional_adult,    ->(user=nil) { without_adult unless user.try(:adult?) && !user.try(:settings).try(:hide_adult_posts?) }
  scope :displayable,          ->(user=nil) { not_banned.not_removed.no_moderation.conditional_adult(user) unless Rails.env.archive? }
  scope :includes_for_display, -> {
    includes(
      author: [:favorites_all, :fans_all, :posts],
      favorite_replies: [:user]
    ).order(created_at: :asc, id: :asc)
  }

  def safe?; !marked_as_adult?; end
  def removed?; removed_at? || post.removed?; end

  def unquoted_text
    text = body.dup
    loop do
      last_start_quote_idx = text.rindex(/\[quote(.*?)\]/)
      break if last_start_quote_idx.nil?
      next_end_quote_idx = text[last_start_quote_idx..-1].index(/\[\/quote\]/)
      break if next_end_quote_idx.nil?
      next_end_quote_idx += last_start_quote_idx + 7

      text[last_start_quote_idx..next_end_quote_idx] = ""
    end
    text
  end

  def username
    if posted_anonymously?
      "Anonymous"
    else
      author.username
    end
  end

  def avatar(size: nil)
    if posted_anonymously?
      author.anonicon(post_id)
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

  def countable?
    !author.helpbot? && !removed? && !in_moderation?
  end

  private

  def update_popular_post
    return if Rails.env.archive?
    UpdatePopularPostWorker.perform_async
  end

  def broadcast_creation
    return if hide_update || Rails.env.archive?
    mod_message = in_moderation? ? "<a href=\"/mod/queue\">There is a new reply that requires approval.</a>" : ""
    User.mod.each do |mod|
      ActionCable.server.broadcast("notifications_#{mod.id}", message: mod_message)
    end

    ActionCable.server.broadcast("replies_for_#{post_id}", {})
  end

  def post_is_open
    return unless post.closed? || post.removed?
    return unless new_obj? # Only prevent creating new replies on a closed post.

    errors.add(:base, "We're very sorry- but this post has been closed.")
  end

  def debounce_replies
    return unless new_record? # Only prevent creating new replies when debouncing
    return if author.replies.where("created_at > ?", 5.seconds.ago).where.not(id: id).none?

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
    return if Rails.env.archive?
    subscription = Subscription.find_or_create_by(user_id: author_id, post_id: post_id) unless author.helpbot?
    post.notify_subscribers(not_user: author, reply_id: id)

    if created_at == updated_at && in_moderation?
      link = url_for(route_for(:post_path, id: post_id, anchor: "reply-#{id}"))
      SlackNotifier.notify("A new message requires moderation from #{author.username}.\n<#{link}|Click Here to view>")
    end
  end

  def invite_users
    return if Rails.env.archive?
    return if has_invited
    self.has_invited = true
    newly_invited_users = []
    tags_to_replace = []
    unquoted_text.scan(/(?:[^\\]?@([^\s\`\@]+))/).flatten.each do |username_tag|
      user_to_invite = User.by_username(username_tag)
      next if user_to_invite.nil?
      tags_to_replace << ["@#{username_tag.first(user_to_invite.slug.length)}", user_to_invite]
      invite = user_to_invite.invites.find_or_initialize_by(post: post, from_user: author, reply: self)
      invite.invited_anonymously = posted_anonymously?
      not_invited_yet = user_to_invite.subscriptions.where(post_id: post_id).none?
      can_be_invited = (user_to_invite.friends?(author) || !user_to_invite.settings.friends_only?) && !user_to_invite.helpbot?
      newly_invited_users << user_to_invite if !invite.persisted? && not_invited_yet && can_be_invited
      invite.save
    end
    replaced_invites = body.dup
    tags_to_replace.uniq.each do |username_tag, user_to_invite|
      replaced_invites = replaced_invites.gsub(username_tag, "@[#{user_to_invite.username}:#{user_to_invite.id}]")
    end
    self.body = replaced_invites if tags_to_replace.any? && body != replaced_invites
    if newly_invited_users.any?
      post.post_invites.create(user_id: author_id, invited_users: newly_invited_users.count, invited_anonymously: posted_anonymously?)
    end
  end

  def format_body
    return if Rails.env.archive?
    if new_obj? && !author.trusted_user?
      has_adult_words = Tag.sounds_nsfw?(body)
      is_verified_user = author.verified?
      contains_link = body =~ url_regex
      self.in_moderation = has_adult_words || (!is_verified_user && contains_link)
    end
  end
end
