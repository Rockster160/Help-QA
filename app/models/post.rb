# == Schema Information
#
# Table name: posts
#
#  id                 :integer          not null, primary key
#  body               :text
#  author_id          :integer
#  posted_anonymously :boolean
#  closed_at          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reply_count        :integer
#

class Post < ApplicationRecord
  include PgSearch
  include Anonicon
  include Defaults

  DEFAULT_POST_TEXT = "Start Here.\n\nAsk a question, post a rant, tell us your story.".freeze

  belongs_to :author, class_name: "User"
  has_many :views, class_name: "PostView"
  has_many :edits, class_name: "PostEdit"
  has_many :replies
  has_many :subscriptions
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :post_tags
  has_many :tags, through: :post_tags
  has_many :favorite_replies
  has_one :poll

  pg_search_scope :search_for, against: :body
  scope :claimed,              -> { where.not(posted_anonymously: true) }
  scope :unclaimed,            -> { where(posted_anonymously: true) }
  scope :verified_user,        -> { joins(:author).where.not(users: { verified_at: nil }) }
  scope :unverified_user,      -> { joins(:author).where(users: { verified_at: nil }) }
  scope :no_replies,           -> { where("posts.reply_count = 0 OR posts.reply_count IS NULL") }
  scope :more_replies_than,    ->(count_of_replies) { where("posts.reply_count > ?", count_of_replies) }
  scope :less_replies_than_or, ->(count_of_replies) { where("posts.reply_count <= ?", count_of_replies) }
  scope :by_username,          ->(username) { claimed.joins(:author).where("users.username ILIKE ?", "%#{username}%") }
  scope :by_tags,              ->(*tags) { joins(:tags).where(tags: { tag_name: tags.flatten.map(&:downcase).map(&:squish) }).distinct }

  after_create :auto_add_tags
  after_create :generate_poll
  defaults reply_count: 0
  defaults posted_anonymously: false

  validate :body_is_not_default
  validate :body_has_alpha_characters

  def self.text_matches_default_text?(text)
    stripped_default_text = DEFAULT_POST_TEXT.gsub("\n", " ").gsub(/[^a-z| ]/i, "")
    stripped_body_text = text.gsub("\n", " ").gsub(/[^a-z| ]/i, "")

    stripped_default_text.include?(stripped_body_text) || stripped_body_text.include?(stripped_default_text)
  end

  def self.currently_popular
    all.sample # FIXME - How do we calculate this?
  end

  def title
    return "BROKEN" unless body.present?
    first_sentence = body.split(/[\!|\.|\n|;|\?|\r] /).reject(&:blank?).first
    body[0..first_sentence.try(:length) || -1].gsub(/\[poll\]/, "")
  end

  def open?; !closed?; end
  def closed?; closed_at?; end

  def notify_subscribers(not_user: nil)
    subscribers.each do |subscriber|
      next if subscriber == not_user
      post_url = Rails.application.routes.url_helpers.post_path(id)
      subscriber.notices.subscriptions.create(title: "New Comment on #{title}", url: post_url)
    end
  end

  def preview_content
    body[title.length..-1].split("\n").reject(&:blank?).first
  end

  def username
    if posted_anonymously?
      "Anonymous"
    else
      author.username
    end
  end

  def avatar
    if posted_anonymously?
      anonicon_src(author.ip_address)
    else
      author.avatar_url.presence || letter.presence || 'status_offline.png'
    end
  end

  def letter
    author.try(:letter) || "?"
  end

  def location
    return unless author.try(:location)
    [author.location.city.presence, author.location.region_code.presence, author.location.country_code.presence].compact.join(", ")
  end

  def to_param
    [id, title.parameterize].join("-")
  end

  private

  def generate_poll
    poll_regex = /\[poll (.*?)\]/
    poll_markdown = body[poll_regex]
    return unless poll_markdown.present?

    options_text = poll_markdown[6..-2].to_s
    options = options_text.split(",").map(&:presence).compact
    return unless options.length >= 2

    poll = build_poll
    poll.save
    options.each do |option|
      poll.options.create(body: option)
    end

    update(body: body.sub(poll_regex, "[poll]"))
  end

  def body_is_not_default
    if Post.text_matches_default_text?(body)
      errors.add(:base, "Try asking a question!")
    end
  end

  def body_has_alpha_characters
    unless body.present? && body.gsub(/[^a-z]/, "").length > 10
      errors.add(:base, "This post isn't long enough!")
    end
  end

  def auto_add_tags
    new_tag_strs = Tag.auto_extract_tags_from_body(body).first(5)
    new_tag_strs.each do |new_tag_str|
      new_tag = Tag.find_or_create_by(tag_name: new_tag_str.to_s.downcase)
      post_tags.create(tag: new_tag)
    end
  end

  def short_title
    cut_title = cut_string_before_index_at_char(title, 100)
    return cut_title if cut_title.length <= 100
    "#{cut_title}..."
  end

  def cut_string_before_index_at_char(str, idx, letter=" ")
    return str if str.length <= idx
    indices_of_letter = str.split("").map.with_index { |l, i| i if l == letter }.compact
    indices_before_index = indices_of_letter.select { |i| i <= idx }
    str[0..indices_before_index.last.to_i - 1]
  end

  def anonicon_src(ip)
    Anonicon.generate(ip)
  end

end
