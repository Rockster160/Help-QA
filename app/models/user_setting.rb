# == Schema Information
#
# Table name: user_settings
#
#  id                            :integer          not null, primary key
#  user_id                       :integer
#  hide_adult_posts              :boolean          default("true")
#  censor_inappropriate_language :boolean          default("true")
#  last_email_sent               :datetime
#  send_email_notifications      :boolean          default("true")
#  send_reply_notifications      :boolean          default("true")
#  default_anonymous             :boolean          default("false")
#  friends_only                  :boolean          default("false")
#

class UserSetting < ApplicationRecord
  include Sherlockable

  sherlockable klass: :user, ignore: [ :last_email_sent ]
  belongs_to :user

  before_validation :set_required

  after_commit :reset_cache

  delegate :child?, to: :user

  private

  def reset_cache
    # ActionController::Base.new.expire_fragment("invite_loader") if previous_changes.keys.include?("friends_only")
  end

  def set_required
    unless user.adult?
      self.hide_adult_posts = true
      self.censor_inappropriate_language = true
    end
  end
end
