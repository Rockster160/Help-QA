class AddToSherlock < ActiveRecord::Migration[5.0]
  def change
    add_column :sherlocks, :acting_ip, :inet
    add_column :sherlocks, :explanation, :text
    add_column :sherlocks, :discovery, :integer
    rename_column :sherlocks, :changed_by_id, :acting_user_id

    Sherlock.where(obj_klass: "User").update_all(discovery: 002) # Edit user
    Sherlock.where(obj_klass: "Post").update_all(discovery: 102) # Edit post
    Sherlock.where(obj_klass: "Reply").update_all(discovery: 202) # Edit reply
  end
end
