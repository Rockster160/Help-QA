class CounterCacheFavorites < ActiveRecord::Migration[5.0]
  def change
    add_column :replies, :favorite_count, :integer, default: 0
  end
end
