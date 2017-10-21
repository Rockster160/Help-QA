class AddModdableAttributes < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :bio, :text
    add_column :users, :can_use_chat, :boolean, default: true
    add_column :users, :banned_until, :datetime

    create_table :banned_ips do |t|
      t.inet :ip
      t.datetime :created_at
    end
  end
end
