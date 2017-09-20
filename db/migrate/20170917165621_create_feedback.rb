class CreateFeedback < ActiveRecord::Migration[5.0]
  def change
    create_table :feedbacks do |t|
      t.belongs_to :user
      t.string     :email
      t.text       :body
      t.string     :url
      t.datetime   :completed_at
      t.belongs_to :completed_by

      t.timestamps
    end
  end
end
