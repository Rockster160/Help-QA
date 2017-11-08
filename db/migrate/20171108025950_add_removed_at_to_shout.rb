class AddRemovedAtToShout < ActiveRecord::Migration[5.0]
  def change
    add_column :shouts, :removed_at, :datetime
  end
end
