class AddAttributesForUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string
    add_column :users, :last_seen_at, :datetime
    add_column :users, :avatar_url, :string

    create_table :locations do |t|
      t.belongs_to :user

      t.string :ip
      t.string :country_code
      t.string :country_name
      t.string :region_code
      t.string :region_name
      t.string :city
      t.string :zip_code
      t.string :time_zone
      t.string :metro_code
      t.float :latitude
      t.float :longitude
    end
  end
end
