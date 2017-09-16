class AddBioToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :has_updated_username, :boolean, default: false
    add_column :users, :bio, :text
  end
end
