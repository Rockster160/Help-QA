# This is a helper class to perform IP lookups. Geocoder's API previously used
#   freegeoip like we're using here, but is having issues connecting. This is
#   essentially just a helper extension to give us the lookup we need.
class Geolocate < Struct.new(:ip, :country_code, :country_name, :region_code, :region_name, :city, :zip_code, :time_zone, :latitude, :longitude, :metro_code)

  def self.lookup(ip)
    return unless ip.present?
    begin
      geoip_response = ::RestClient.get("freegeoip.net/json/#{ip}").body
    rescue StandardError
      return
    end
    geoip_json = JSON.parse(geoip_response)
    new(geoip_json)
  end

  def initialize(attrs)
    attrs.each do |attr_key, attr_val|
      self.send("#{attr_key}=", attr_val)
    end
    self
  end

end
