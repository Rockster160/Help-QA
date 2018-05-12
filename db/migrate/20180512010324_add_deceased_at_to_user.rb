class AddDeceasedAtToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deceased_at, :datetime
  end
end
