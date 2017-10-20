class CreateUserProfile < ActiveRecord::Migration[5.0]
  def change
    create_table :user_profiles do |t|
      t.belongs_to :user
      t.text :about
      t.text :grow_up
      t.text :live_now
      t.text :education
      t.text :subjects
      t.text :sports
      t.text :jobs
      t.text :hobbies
      t.text :causes
      t.text :political
      t.text :religion

      t.timestamps
    end
  end
end
