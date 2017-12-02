class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat"
    user_connected
  end

  def unsubscribed
    user_disconnected
  end

  def speak(data)
    return unless current_user.try(:can_use_chat?)
    current_user.chat_messages.create(body: data["message"], acting_user_id: current_user.id)
  end

  def pong(data: nil)
    @token = data&.dig(:guest_token)
    user_connected(send_list: false)
  end

  private

  def current_username
    @current_username ||= current_user.try(:username) || "Guest #{@token ||= ('a'..'z').to_a.sample(10).join("")}"
  end

  def send_user_list
    rendered_message = ChatController.render partial: "chat/online_list"
    ActionCable.server.broadcast "chat", users: rendered_message, token: @token
  end

  def user_disconnected
    current_users = Rails.cache.fetch("users_chatting") { {} }
    current_users = current_users.reject { |username, last_pinged| username == current_username }
    Rails.cache.write("users_chatting", current_users)
    send_user_list
  end

  def user_connected(send_list: true, guest_token: nil)
    current_users = Rails.cache.fetch("users_chatting") { {} }
    current_users = {} if current_users.nil? || current_users.is_a?(Array)
    already_existed = current_users.key?(current_username)
    current_users[current_username] = DateTime.current
    current_users = current_users.reject do |username, last_pinged|
      last_pinged < 5.minutes.ago
    end
    Rails.cache.write("users_chatting", current_users)
    send_user_list if send_list || !already_existed
  end
end
