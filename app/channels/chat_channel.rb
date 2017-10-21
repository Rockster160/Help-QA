class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat"
    refresh_users
  end

  def unsubscribed
    refresh_users
  end

  def speak(data)
    return unless current_user
    current_user.chat_messages.create(body: data["message"])
  end

  def refresh_users
    Rails.cache.write("users_chatting", [])
    ActionCable.server.broadcast("chat", {ping: true})
  end

  def pong
    user_connected
    send_user_list
  end

  private

  def current_username
    @current_username ||= current_user.try(:username) || "Guest"
  end

  def send_user_list
    rendered_message = ChatController.render partial: "chat/online_list"
    ActionCable.server.broadcast "chat", users: rendered_message
  end

  def user_connected
    current_users = [Rails.cache.read("users_chatting")].flatten
    current_users << current_username
    Rails.cache.write("users_chatting", current_users)
  end
end
