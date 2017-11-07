class AddSuperIpToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :super_ip, :inet
  end
end
