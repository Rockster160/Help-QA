class ModChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mod_chat"
    user_connected
  end

  def unsubscribed
    user_disconnected
  end

  def speak(data)
    return unless current_user.mod?
    current_user.mod_messages.create(body: data["message"])
  end

  def pong
    user_connected(send_list: false)
  end

  private

  def current_username
    @current_username ||= current_user.username
  end

  def send_user_list
    rendered_message = ChatController.render(partial: "chat/online_list", locals: { usernames: Rails.cache.fetch("mods_chatting") { {} } })
    ActionCable.server.broadcast "mod_chat", users: rendered_message
  end

  def user_disconnected
    current_users = Rails.cache.fetch("mods_chatting") { {} }
    current_users = current_users.reject { |username, last_pinged| username == current_username }
    Rails.cache.write("mods_chatting", current_users)
    send_user_list
  end

  def user_connected(send_list: true)
    current_users = Rails.cache.fetch("mods_chatting") { {} }
    current_users = {} if current_users.nil? || current_users.is_a?(Array)
    already_existed = current_users.key?(current_username)
    current_users[current_username] = DateTime.current
    current_users = current_users.reject do |username, last_pinged|
      last_pinged < 5.minutes.ago
    end
    Rails.cache.write("mods_chatting", current_users)
    send_user_list if send_list || !already_existed
  end
end
