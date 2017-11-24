# == Schema Information
#
# Table name: banned_ips
#
#  id           :integer          not null, primary key
#  ip           :inet
#  created_at   :datetime
#  banned_until :datetime
#

class BannedIp < ApplicationRecord
  include Sherlockable

  sherlockable klass: :ip, skip: :new

  scope :current, -> { where("banned_ips.banned_until IS NULL OR banned_ips.banned_until > ?", DateTime.current) }
end
