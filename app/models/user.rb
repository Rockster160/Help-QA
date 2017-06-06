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
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  has_many :posts, foreign_key: :author_id
  has_many :comments, foreign_key: :author_id
  has_many :post_edits, foreign_key: :edited_by_id
  has_many :post_views, foreign_key: :viewed_by_id
  has_many :report_flags
  has_many :subscriptions
  has_one :location

  validates_uniqueness_of :username
  validate :username_meets_requirements
  scope :order_by_last_online, -> { order("last_seen_at DESC NULLS LAST") }
  scope :online_now, -> { order_by_last_online.where("last_seen_at > ?", 5.minutes.ago) }

  def online?
    return false unless last_seen_at
    last_seen_at > 5.minutes.ago
  end
  def offline?; !online?; end

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
    username.parameterize || id
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
