class CreateShouts < ActiveRecord::Migration[5.0]
  def change
    create_table :shouts do |t|
      t.belongs_to :sent_from
      t.belongs_to :sent_to
      t.text :body

      t.timestamps
    end
  end
end
