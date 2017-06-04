# == Schema Information
#
# Table name: locations
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  ip           :string
#  country_code :string
#  country_name :string
#  region_code  :string
#  region_name  :string
#  city         :string
#  zip_code     :string
#  time_zone    :string
#  metro_code   :string
#  latitude     :float
#  longitude    :float
#

class Location < ApplicationRecord
  belongs_to :user
end
