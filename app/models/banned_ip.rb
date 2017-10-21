# == Schema Information
#
# Table name: banned_ips
#
#  id         :integer          not null, primary key
#  ip         :inet
#  created_at :datetime
#

class BannedIp < ApplicationRecord
end
