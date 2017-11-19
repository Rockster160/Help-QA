# == Schema Information
#
# Table name: sherlocks
#
#  id                      :integer          not null, primary key
#  acting_user_id          :integer
#  obj_klass               :string
#  obj_id                  :integer
#  previous_attributes_raw :text
#  new_attributes_raw      :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  acting_ip               :inet
#  explanation             :text
#  discovery               :integer
#

class Sherlock < ApplicationRecord
  belongs_to :acting_user, class_name: "User"

  validate :some_changes_made

  after_commit :broadcast_creation

  enum discovery: {
    # unknown: nil

    # New x00
    # Edit x02
    # Remove x04
    # Ban x05

    #-- Users: 0xx
    new_user:     000,
    edit_user:    002,
    remove_user:  004,
    ban_user:     005,

    #-- Posts: 1xx
    new_post:     100,
    edit_post:    102,
    remove_post:  104,
    # ban_post:     105,

    #-- Replies: 2xx
    new_reply:    200,
    edit_reply:   202,
    remove_reply: 204,
    # ban_reply:    205,

    #-- Chat: 3xx
    new_chat:     300,
    # edit_chat:    302,
    remove_chat:  304,
    # ban_chat:     305,

    #-- Shouts: 4xx
    new_shout:    400,
    edit_shout:   402,
    remove_shout: 404,
    # ban_shout:    405,

    #-- IP: 9xx
    # new_ip:       900,
    # edit_ip:      902,
    # remove_ip:    904,
    ban_ip:       905
  }

  def self.notifications_for(post)
    where(obj_klass: "Post", obj_id: post.id)
  end
  def self.user_changes(user)
    where(obj_klass: "User", obj_id: user.id)
  end

  def self.by_changed_attr(*change_keys)
    select { |sherlock| (changes.keys & change_keys.map(&:to_s)).any? }
  end

  def self.update_by(person, obj_to_update, new_params, method: :update)
    new_sherlock = person.sherlocks.new(acting_ip: person.try(:current_sign_in_ip).presence || person.try(:last_sign_in_ip).presence || person.try(:ip_address).presence)

    new_sherlock.previous_attributes_raw = obj_to_update.attributes.except("updated_at").to_json
    obj_to_update.update(new_params)
    if obj_to_update.persisted? && obj_to_update.try(:errors).try(:none?)
      new_sherlock.new_attributes_raw = obj_to_update.reload.attributes.except("updated_at").to_json

      new_sherlock.obj = obj_to_update
      new_sherlock.save
    end

    obj_to_update
  end

  def obj
    obj_klass.constantize.find(obj_id)
  end

  def obj=(new_obj)
    self.obj_klass = new_obj.class.to_s
    self.obj_id = new_obj.try(:id)
  end

  def previous_attributes
    @previous_attributes ||= JSON.parse(previous_attributes_raw.to_s) rescue {}
  end

  def new_attributes
    @new_attributes ||= JSON.parse(new_attributes_raw.to_s) rescue {}
  end

  def changes
    diff = previous_attributes.dup
    diff.delete_if { |prev_key, prev_val| new_attributes[prev_key] == prev_val }
    diff.each do |changed_key, changed_val|
      diff[changed_key] = [changed_val, new_attributes[changed_key]]
    end
    diff
  end

  private

  def broadcast_creation
    if obj_klass == "Post"
      ActionCable.server.broadcast("replies_for_#{obj_id}", {})
    end
  end

  def some_changes_made
    return if changes.any?

    errors.add(:base, "No changes made.")
  end
end
