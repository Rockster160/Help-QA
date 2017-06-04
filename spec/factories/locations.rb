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

FactoryGirl.define do
  factory :location do
    user
    ip (0..255).to_a.sample(4).join(".")
    country_code "US"
    country_name "United States"
    region_code "UT"
    region_name "Utah"
    city "Sandy"
    zip_code "84095"
    time_zone "America/Denver"
    metro_code "770"
    latitude 40.6097
    longitude -111.9391
  end
end
