class CreateUserSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :user_settings do |t|
      t.belongs_to :user
      t.boolean :hide_adult_posts,              default: true
      t.boolean :censor_inappropriate_language, default: true
    end
  end
end
