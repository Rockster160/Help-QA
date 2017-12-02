class CreateModMessage < ActiveRecord::Migration[5.0]
  def change
    create_table :mod_messages do |t|
      t.belongs_to :author
      t.text :body

      t.timestamps
    end
  end
end
