# == Schema Information
#
# Table name: user_settings
#
#  id                            :integer          not null, primary key
#  user_id                       :integer
#  hide_adult_posts              :boolean          default("true")
#  censor_inappropriate_language :boolean          default("true")
#

# NOTE: Settings should always default to true
class UserSetting < ApplicationRecord
  belongs_to :user

  def editable_properties
    {
      hide_adult_posts: "",
      censor_inappropriate_language: ""
    }
  end

  def html_properties_for_settings
    editable_properties.keys.join(" ")
  end
end
