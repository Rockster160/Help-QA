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
  include PgSearch
  include UrlHelper
  belongs_to :user, optional: true
  belongs_to :completed_by, optional: true, class_name: "User"

  validate :message_exists
  validate :can_follow_up
  after_create :notify_slack

  pg_search_scope :search_for, against: :body
  scope :unresolved, -> { where(completed_at: nil) }
  scope :resolved, -> { where.not(completed_at: nil) }
  scope :by_username, ->(username) { where.not(user_id: nil).joins(:user).where("users.username ILIKE ?", "%#{username}%") }

  def resolved?; completed_at?; end
  def unresolved?; !resolved?; end

  def display_name
    user.try(:username) || email
  end

  def resolve(user)
    update(completed_by: user, completed_at: DateTime.current)
  end

  private

  def notify_slack
    slack_message = "New Feedback from #{display_name}"
    link_url = url_for(Rails.application.routes.url_helpers.edit_feedback_path(id))
    attachment = {
      pretext: slack_message,
      fallback: "#{body} - Ticket: ##{id}: #{link_url}",
      title: slack_message,
      title_link: link_url,
      text: body,
      color: :good
    }
    SlackNotifier.notify(slack_message, attachments: [attachment])
  end

  def message_exists
    return unless body.blank?

    errors.add(:base, "Please leave a description (is as much detail as you can) about the problem or issue you are experiencing.")
  end

  def can_follow_up
    return if user.present? || (email.present? && email =~ Devise.email_regexp)

    errors.add(:email, "must be a valid email address.")
  end
end
