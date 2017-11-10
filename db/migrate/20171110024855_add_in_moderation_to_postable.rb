class AddInModerationToPostable < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :in_moderation, :boolean, default: false
    add_column :replies, :in_moderation, :boolean, default: false
    remove_column :replies, :has_questionable_text, :boolean
  end
end
