class AddUrlToNotice < ActiveRecord::Migration[5.0]
  def change
    add_column :notices, :url, :string
    add_column :subscriptions, :unsubscribed, :boolean
    remove_column :notices, :notice_for_id, :integer
    remove_column :notices, :description, :string
  end
end
