# == Schema Information
#
# Table name: user_settings
#
#  id                            :integer          not null, primary key
#  user_id                       :integer
#  hide_adult_posts              :boolean          default("true")
#  censor_inappropriate_language :boolean          default("true")
#

class UserSetting < ApplicationRecord
  belongs_to :user

  before_validation :set_required

  delegate :child?, to: :user

  def editable_properties
    {
      hide_adult_posts: [:child?, ""],
      censor_inappropriate_language: [:child?, ""]
    }
  end

  private

  def set_required
    unless user.adult?
      self.hide_adult_posts = true
      self.censor_inappropriate_language = true
    end
  end
end
