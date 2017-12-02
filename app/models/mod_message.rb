# == Schema Information
#
# Table name: mod_messages
#
#  id         :integer          not null, primary key
#  author_id  :integer
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ModMessage < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :author_id

  validates :body, presence: true

  after_commit :broadcast_creation

  private

  def broadcast_creation
    ActionCable.server.broadcast "mod_chat", message: id
  end
end
