class CreateEmailBlob < ActiveRecord::Migration[5.0]
  def change
    create_table :email_blobs do |t|
      t.string :notification_type
      t.string :subject
      t.string :from
      t.string :to
      t.boolean :spam
      t.boolean :virus
      t.text :text
      t.text :blob
      t.datetime :date

      t.timestamps
    end
  end
end
