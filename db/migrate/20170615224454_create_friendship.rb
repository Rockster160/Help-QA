class CreateFriendship < ActiveRecord::Migration[5.0]
  def change
    create_table :friendships do |t|
      t.belongs_to :user
      t.belongs_to :friend

      t.datetime :accepted_at
      t.datetime :created_at
    end
  end
end
