class CreateNotice < ActiveRecord::Migration[5.0]
  def change
    create_table :notices do |t|
      t.belongs_to :user
      t.integer :notice_type
      t.string :title
      t.string :description
      t.datetime :read_at
      t.datetime :created_at
    end
  end
end
