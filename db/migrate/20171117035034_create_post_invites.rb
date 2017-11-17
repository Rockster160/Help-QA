class CreatePostInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :post_invites do |t|
      t.belongs_to :post, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :invited_users
      t.boolean :invited_anonymously

      t.timestamps
    end
    add_column :invites, :invited_anonymously, :boolean, default: false
  end
end
