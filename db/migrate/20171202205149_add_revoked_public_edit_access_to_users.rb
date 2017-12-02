class AddRevokedPublicEditAccessToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :revoked_public_edit_access, :boolean
  end
end
