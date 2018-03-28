class AddReadAtToEmailBlob < ActiveRecord::Migration[5.0]
  def change
    add_column :email_blobs, :read_at, :datetime
  end
end
