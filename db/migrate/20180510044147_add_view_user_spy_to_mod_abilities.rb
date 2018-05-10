class AddViewUserSpyToModAbilities < ActiveRecord::Migration[5.0]
  def change
    add_column :mod_abilities, :view_user_spy, :boolean, default: false

    User.mod.find_each do |user|
      user.abilities.update(view_user_spy: true)
    end
  end
end
