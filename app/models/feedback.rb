# == Schema Information
#
# Table name: feedbacks
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  email           :string
#  body            :text
#  url             :string
#  completed_at    :datetime
#  completed_by_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Feedback < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :completed_by, optional: true, class_name: "User"

  validate :message_exists
  validate :can_follow_up

  private

  def message_exists
    return unless body.blank?

    errors.add(:base, "Please leave a description (is as much detail as you can) about the problem or issue you are experiencing.")
  end

  def can_follow_up
    return if user.present? || (email.present? && email =~ Devise.email_regexp)

    errors.add(:email, "must be a valid email address.")
  end
end
