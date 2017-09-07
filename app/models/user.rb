# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  last_seen_at           :datetime
#  avatar_url             :string
#  verified_at            :datetime
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  include Friendable
  has_paper_trail
  # before_action :set_paper_trail_whodunnit - Add to controller

  has_many :posts,            foreign_key: :author_id
  has_many :replies,          foreign_key: :author_id
  has_many :post_edits,       foreign_key: :edited_by_id
  has_many :post_views,       foreign_key: :viewed_by_id
  has_many :shouts_to,        foreign_key: :sent_to_id,      class_name: "Shout"
  has_many :shouts_from,      foreign_key: :sent_from_id,    class_name: "Shout"
  has_many :invites_sent,     foreign_key: :from_user_id,    class_name: "Invite"
  has_many :invites_received, foreign_key: :invited_user_id, class_name: "Invite"
  has_many :tags_from_posts,   source: :tags, through: :posts
  has_many :tags_from_replies, source: :tags, through: :replies
  has_many :notices
  has_many :report_flags
  has_many :subscriptions
  has_one  :location

  validates_uniqueness_of :username
  validate :username_meets_requirements

  scope :order_by_last_online, -> { order("last_seen_at DESC NULLS LAST") }
  scope :online_now,           -> { order_by_last_online.where("last_seen_at > ?", 5.minutes.ago) }
  scope :unverified,           -> { where(verified_at: nil) }
  scope :verified,             -> { where.not(verified_at: nil) }
  scope :search_username,      ->(username) { where("users.username ILIKE ?", "%#{username}%") }

  def admin?; false; end # FIXME by adding roles
  def mod?;   false; end # FIXME by adding roles

  def recent_shouts
    shouts_to.where("created_at > ?", 30.days.ago)
  end

  def online?
    return false unless last_seen_at
    last_seen_at > 5.minutes.ago
  end
  def offline?; !online?; end
  def verified?; verified_at?; end
  def long_term_user?; created_at < 1.year.ago; end

  def see!
    update(last_seen_at: DateTime.current)
  end

  def ip_address
    location.try(:ip) || current_sign_in_ip || last_sign_in_ip || username || email || id
  end

  def letter
    return "?" unless username.present?
    (username.gsub(/[^a-z]/i, '').first.presence || "?").upcase
  end

  def avatar
    avatar_url.presence || letter.presence || 'status_offline.png'
  end

  def to_param
    [id, username.parameterize].join("-")
  end

  private

  def username_meets_requirements
    self.username ||= email.split("@").first
    # Profanity filter?
    username.squish!
    if username.include?(" ")
      errors.add(:username, "cannot contain spaces")
    end
    unless username.length > 3
      errors.add(:username, "must be at least 4 characters")
    end
    unless username.gsub(/[^a-z]/i, "").length > 1
      errors.add(:username, "must have at least 2 normal alpha characters (A-Z)")
    end
  end

end
