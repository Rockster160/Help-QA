class AddBannedUntilToBannedIp < ActiveRecord::Migration[5.0]
  def change
    add_column :banned_ips, :banned_until, :datetime
  end
end
