class AddUpdatedAtToNotice < ActiveRecord::Migration[5.0]
  def change
    add_column :notices, :updated_at, :datetime
  end
end
