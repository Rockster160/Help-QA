class AddRemovedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :removed_at, :datetime
  end
end
