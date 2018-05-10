# == Schema Information
#
# Table name: mod_abilities
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  ip_banning           :boolean          default("false")
#  ban_users            :boolean          default("false")
#  revoke_chat_ability  :boolean          default("false")
#  remove_chat_messages :boolean          default("false")
#  remove_shouts        :boolean          default("false")
#  remove_whispers      :boolean          default("false")
#  view_anonymous_user  :boolean          default("false")
#  view_user_details    :boolean          default("false")
#  view_user_email      :boolean          default("false")
#  post_moderation      :boolean          default("false")
#  adult_mark_posts     :boolean          default("false")
#  edit_posts           :boolean          default("false")
#  remove_posts         :boolean          default("false")
#  reply_moderation     :boolean          default("false")
#  adult_mark_replies   :boolean          default("false")
#  edit_replies         :boolean          default("false")
#  remove_replies       :boolean          default("false")
#  reports_moderation   :boolean          default("false")
#  view_user_spy        :boolean          default("false")
#

# Unused: reports_moderation
# Implied: Can view Audits

class ModAbilities < ApplicationRecord
  belongs_to :user

  def grant(*syms)
    return set_all(true) if syms.include?(:all)
    update(Hash[syms.product([true])])
  end

  def revoke(*syms)
    return set_all(false) if syms.include?(:all)
    update(Hash[syms.product([false])])
  end

  def set_all(bool)
    attrs_to_change = permissable_properties.keys
    update(Hash[attrs_to_change.product([bool])])
  end

  def granted_permissions
    permissions_by_bool(true)
  end

  def unpermitted
    permissions_by_bool(false)
  end

  def permissions_by_bool(bool)
    permissable_properties.select { |k,v| v == bool }.keys
  end

  def permissable_properties
    attributes.reject { |k,v| k.in?(["id", "user_id"]) }.symbolize_keys
  end
end
