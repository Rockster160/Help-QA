class CreateChatMessage < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_messages do |t|
      t.belongs_to :author
      t.text :body
      t.boolean :removed, default: false

      t.timestamps
    end
  end
end
