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

  # has_many :posts
  # has_many :comments
  # has_many :post_edits
  # has_many :post_views
  # has_many :report_flags
  # has_many :subscriptions

  scope :order_by_last_online, -> { order("last_seen_at DESC NULLS LAST") }
  scope :online_now, -> { order_by_last_online.where("last_seen_at > ?", 5.minutes.ago) }

  def see!
    update(last_seen_at: DateTime.current)
  end

end
