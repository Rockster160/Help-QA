class AddAnoniconSeedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :anonicon_seed, :string
  end
end
