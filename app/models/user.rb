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
#  date_of_birth          :date
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  include Friendable
  include DeviseOverrides
  include Accountable
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

  after_create :set_gravatar_if_exists

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

end
