# == Schema Information
#
# Table name: sherlocks
#
#  id                      :integer          not null, primary key
#  changed_by_id           :integer
#  obj_klass               :string
#  obj_id                  :integer
#  previous_attributes_raw :text
#  new_attributes_raw      :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Sherlock < ApplicationRecord
  belongs_to :changed_by, class_name: "User"

  validate :some_changes_made

  def self.notifications_for(post)
    where(obj_klass: "Post", obj_id: post.id)
  end
  def self.user_changes(user)
    where(obj_klass: "User", obj_id: user.id)
  end

  def self.by_changed_attr(*change_keys)
    select { |sherlock| (changes.keys & change_keys.map(&:to_s)).any? }
  end

  def self.update_by(person, obj_to_update, new_params)
    new_sherlock = person.sherlocks.new(obj: obj_to_update)

    new_sherlock.previous_attributes_raw = obj_to_update.attributes.except("updated_at").to_json
    result = obj_to_update.update(new_params)
    new_sherlock.new_attributes_raw = obj_to_update.reload.attributes.except("updated_at").to_json

    new_sherlock.save
    result
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

  def some_changes_made
    return if changes.any?

    errors.add(:base, "No changes made.")
  end
end
