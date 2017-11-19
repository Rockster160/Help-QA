class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat"
    user_connected
  end

  def unsubscribed
    user_disconnected
  end

  def speak(data)
    return unless current_user
    Sherlock.update_by(current_user, current_user.chat_messages.new, {body: data["message"]})
  end

  def pong
    user_connected(send_list: false)
  end

  private

  def current_username
    @current_username ||= current_user.try(:username) || "Guest"
  end

  def send_user_list
    rendered_message = ChatController.render partial: "chat/online_list"
    ActionCable.server.broadcast "chat", users: rendered_message
  end

  def user_disconnected
    current_users = [Rails.cache.read("users_chatting")].flatten.compact
    current_users.delete_at(current_users.index(current_username) || current_users.length)
    Rails.cache.write("users_chatting", current_users)
    send_user_list
  end

  def user_connected(send_list: true)
    current_users = [Rails.cache.read("users_chatting")].flatten.compact
    if current_username == "Guest" || current_users.exclude?(current_username)
      current_users << current_username
    end
    Rails.cache.write("users_chatting", current_users)
    send_user_list if send_list
  end
end
