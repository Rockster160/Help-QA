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
#  has_updated_username   :boolean          default("false")
#  bio                    :text
#  slug                   :string
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  include Friendable
  include DeviseOverrides
  include Accountable
  include Postable
  include Moddable
  has_paper_trail
  # before_action :set_paper_trail_whodunnit - Add to controller

  has_one  :location

  after_create :set_gravatar_if_exists

  scope :order_by_last_online, -> { order("last_seen_at DESC NULLS LAST") }
  scope :online_now,           -> { order_by_last_online.where("last_seen_at > ?", 5.minutes.ago) }
  scope :unverified,           -> { where(verified_at: nil) }
  scope :verified,             -> { where.not(verified_at: nil) }
  scope :search_username,      ->(username) { where("users.username ILIKE ?", "%#{username}%") }

  def self.help_bot
    by_username("HelpBot")
  end

  def self.by_username(username)
    find_by("users.slug = ?", username.parameterize)
  end

end
