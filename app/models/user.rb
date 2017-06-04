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

  # validates username has at least 1? character

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
    location.try(:ip) || current_sign_in_ip || last_sign_in_ip
  end

  def letter
    return "?" unless username.present?
    (username.gsub(/[^a-z]/i, '').first.presence || "?").upcase
  end

end
