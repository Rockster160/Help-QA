class ChatController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_mod, only: [:remove_message, :revoke_access]

  def chat
    return render :banned if user_signed_in? && !current_user.can_use_chat?
    limit = 10
    @messages = ChatMessage.includes(:author).order(created_at: :desc).limit(limit) # Intentionally ordering backwards so that limit gets the last N records
    @messages = @messages.displayable
    if params[:message].to_i > 0
      start_id = params[:message].to_i - (limit / 2)
      end_id = params[:message].to_i + (limit / 2)
      @messages = @messages.where(id: start_id..end_id)
    end
    if params[:id].to_i > 0
      @messages = @messages.where(id: params[:id])
    end
    if params[:since].to_i > 0
      @messages = @messages.where("chat_messages.created_at > ?", Time.at(params[:since].to_i + 1))
    end
    @messages = @messages.reverse # Array reversal so that we get the LAST N records instead of the first.
    render partial: "messages" if request.xhr?
  end

  def chat_list
    respond_to do |format|
      format.json { render json: { count: number_of_users_in_chat }}
    end
  end

  def remove_message
    message = ChatMessage.find(params[:id])
    message.update(removed: params[:restore] != "true")
    redirect_to chat_path
  end

  def revoke_access
    user = User.find(params[:id])
    user.update(can_use_chat: false)
    redirect_to chat_path
  end

end
