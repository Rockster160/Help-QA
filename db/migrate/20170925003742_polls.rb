class Polls < ActiveRecord::Migration[5.0]
  def change
    create_table :polls do |t|
      t.belongs_to :post

      t.timestamps
    end
    create_table :poll_options do |t|
      t.belongs_to :poll
      t.string :body

      t.timestamps
    end
    create_table :user_poll_votes do |t|
      t.belongs_to :user
      t.belongs_to :poll_option

      t.timestamps
    end
  end
end
