class ChatController < ApplicationController
  skip_before_action :verify_authenticity_token

  def chat
    @messages = ChatMessage.not_banned.not_removed.order(created_at: :asc)
    render partial: "messages" if request.xhr?
  end

end
