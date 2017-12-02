class CreateModAbilities < ActiveRecord::Migration[5.0]
  def change
    create_table :mod_abilities do |t|
      t.belongs_to :user
      t.boolean :ip_banning,           default: false
      t.boolean :ban_users,            default: false
      t.boolean :revoke_chat_ability,  default: false
      t.boolean :remove_chat_messages, default: false
      t.boolean :remove_shouts,        default: false
      t.boolean :remove_whispers,      default: false
      t.boolean :view_anonymous_user,  default: false
      t.boolean :view_user_details,    default: false
      t.boolean :view_user_email,      default: false
      t.boolean :post_moderation,      default: false
      t.boolean :adult_mark_posts,     default: false
      t.boolean :edit_posts,           default: false
      t.boolean :remove_posts,         default: false
      t.boolean :reply_moderation,     default: false
      t.boolean :adult_mark_replies,   default: false
      t.boolean :edit_replies,         default: false
      t.boolean :remove_replies,       default: false
      t.boolean :reports_moderation,   default: false
    end
  end
end
