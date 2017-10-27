# == Schema Information
#
# Table name: chat_messages
#
#  id         :integer          not null, primary key
#  author_id  :integer
#  body       :text
#  removed    :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ChatMessage < ApplicationRecord
  belongs_to :author, class_name: "User"

  validates :body, presence: true

  after_commit :broadcast_creation

  scope :not_removed, -> { where(removed: false) }
  scope :not_banned,  -> { joins(:author).where("users.banned_until IS NULL OR users.banned_until < ?", DateTime.current) }

  private

  def broadcast_creation
    rendered_message = ChatController.render partial: "chat/messages", locals: { messages: [self] }
    if removed?
      ActionCable.server.broadcast "chat", removed: id
    else
      ActionCable.server.broadcast "chat", message: rendered_message
    end
  end
end
