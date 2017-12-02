# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  reset_password_token       :string
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default("0"), not null
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :inet
#  last_sign_in_ip            :inet
#  confirmation_token         :string
#  confirmed_at               :datetime
#  confirmation_sent_at       :datetime
#  unconfirmed_email          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  username                   :string
#  last_seen_at               :datetime
#  avatar_url                 :string
#  verified_at                :datetime
#  date_of_birth              :date
#  has_updated_username       :boolean          default("false")
#  slug                       :string
#  role                       :integer          default("0")
#  completed_signup           :boolean          default("false")
#  can_use_chat               :boolean          default("true")
#  banned_until               :datetime
#  authorization_token        :string
#  avatar_image_file_name     :string
#  avatar_image_content_type  :string
#  avatar_image_file_size     :integer
#  avatar_image_updated_at    :datetime
#  super_ip                   :inet
#  revoked_public_edit_access :boolean
#  anonicon_seed              :string
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  include Friendable
  include DeviseOverrides
  include Accountable
  include Postable
  include Moddable
  include Sherlockable
  include Anonicon

  sherlockable klass: :user, ignore: [ :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :super_ip, :confirmation_token, :confirmation_sent_at, :updated_at, :last_seen_at ]

  has_one :location
  has_one :profile,   class_name: "UserProfile",     dependent: :destroy
  has_one :settings,  class_name: "UserSetting",     dependent: :destroy
  has_many :sherlocks, foreign_key: :acting_user_id, dependent: :destroy

  scope :order_by_last_online, -> { order("last_seen_at DESC NULLS LAST") }
  scope :online_now,           -> { order_by_last_online.where("last_seen_at > ?", 5.minutes.ago) }
  scope :not_banned,           -> { where("banned_until IS NULL OR banned_until < ?", DateTime.current) }
  scope :unverified,           -> { where(verified_at: nil) }
  scope :verified,             -> { where.not(verified_at: nil) }
  scope :search_username,      ->(username) { where("users.username ILIKE ?", "%#{username}%") }
  scope :not_helpbot,          -> { where.not(username: "HelpBot") }
  scope :invitable,            -> { joins(:settings).where(user_settings: { friends_only: false }) }
  scope :not_invitable,        -> { joins(:settings).where(user_settings: { friends_only: true }) }
  scope :displayable,          -> { not_helpbot.not_banned }
  scope :search_ip,            ->(ip) {
    begin
      IPAddr.new(ip)
      where("users.super_ip = :ip OR users.super_ip IS NULL AND (users.current_sign_in_ip = :ip OR users.last_sign_in_ip = :ip)", ip: ip)
    rescue IPAddr::InvalidAddressError
      none
    end
  }

  has_attached_file :avatar_image, styles: {
    original: "200x200#",
    tiny: '40x40#',
    small: '100x100#'
  }
  validates_attachment_content_type :avatar_image, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def self.by_username(username)
    loop do
      break if username.length == 0
      user = find_by("users.slug = ?", username.parameterize)
      if user.present?
        break user
      else
        username[-1] = ""
      end
    end
  end

  def current_sign_in_ip; super_ip || super; end
  def last_sign_in_ip; super_ip || super; end

  def helpbot?
    return false unless persisted?
    id == helpbot.id
  end

  def description
    return :admin if admin?
    return :mod if mod?
    return :knowledgable if long_time_user?
    return :active if replies.where("replies.created_at > ?", 1.week.ago).length > 5
    :inactive
  end

  def anonicon
    src = anonicon_seed.presence || ip_address.presence || username.presence || email.presence || id.presence
    Anonicon.generate(src)
  end

end
