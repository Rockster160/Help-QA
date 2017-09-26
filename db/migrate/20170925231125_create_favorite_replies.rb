class CreateFavoriteReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :favorite_replies do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.belongs_to :reply

      t.timestamps
    end
  end
end
