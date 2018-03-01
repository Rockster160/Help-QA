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
  include UrlHelper
  belongs_to :user, optional: true
  belongs_to :completed_by, optional: true, class_name: "User"

  validate :message_exists
  validate :can_follow_up
  after_create :notify_slack
  after_commit :broadcast_creation

  scope :search_for,   ->(text) { where("feedbacks.body ILIKE ?", "%#{text.gsub(/['"’“”]/, "['\"’“”]")}%") }
  scope :regex_search, ->(text) { where("feedbacks.body ~* ?", text.gsub(/['"’“”]/, "['\"’“”]")) }
  scope :unresolved,   -> { where(completed_at: nil) }
  scope :resolved,     -> { where.not(completed_at: nil) }
  scope :by_username,  ->(username) { where.not(user_id: nil).joins(:user).where("users.username ILIKE ?", "%#{username}%") }

  def resolved?; completed_at?; end
  def unresolved?; !resolved?; end

  def display_name
    user.try(:username) || email
  end

  def resolve(user)
    update(completed_by: user, completed_at: DateTime.current)
  end

  private

  def broadcast_creation
    mod_message = unresolved? ? "<a href=\"/mod/queue\">There is a new reply that requires approval.</a>" : ""
    User.mod.each do |mod|
      ActionCable.server.broadcast("notifications_#{mod.id}", message: mod_message)
    end
  end

  def notify_slack
    slack_message = "New Feedback from #{display_name}"
    link_url = url_for(Rails.application.routes.url_helpers.edit_feedback_path(id))
    attachment = {
      fallback: "#{body} - Ticket: ##{id}: #{link_url}",
      title: slack_message,
      title_link: link_url,
      text: "#{body} - Ticket: ##{id}: #{link_url}",
      color: :good
    }
    SlackNotifier.notify("", attachments: [attachment])
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
