class AddFlagsToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :marked_as_adult, :boolean
    add_column :replies, :removed_at, :datetime
    add_column :replies, :marked_as_adult, :boolean
  end
end
