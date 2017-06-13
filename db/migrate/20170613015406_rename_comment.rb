class RenameComment < ActiveRecord::Migration[5.0]
  def change
    rename_table :comments, :replies
    rename_column :report_flags, :comment_id, :reply_id
  end
end
