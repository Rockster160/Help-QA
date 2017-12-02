class ChatListChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_list"
  end
end
