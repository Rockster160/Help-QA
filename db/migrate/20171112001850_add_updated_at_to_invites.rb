class AddUpdatedAtToInvites < ActiveRecord::Migration[5.0]
  def change
    add_column :invites, :updated_at, :datetime
  end
end
