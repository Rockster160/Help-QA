class ModsController < ApplicationController
  before_action :authenticate_mod

  def show
    limit = 100
    @messages = ModMessage.includes(:author).order(created_at: :desc).limit(limit) # Intentionally ordering backwards so that limit gets the last N records
    if params[:message].to_i > 0
      start_id = params[:message].to_i - (limit / 2)
      end_id = params[:message].to_i + (limit / 2)
      @messages = @messages.where(id: start_id..end_id)
    end
    if params[:id].to_i > 0
      @messages = @messages.where(id: params[:id])
    end
    if params[:since].to_i > 0
      @messages = @messages.where("mod_messages.created_at > ?", Time.at(params[:since].to_i + 1))
    end
    @messages = @messages.reverse # Array reversal so that we get the LAST N records instead of the first.
    render partial: "chat/messages" if request.xhr?
  end

  def queue
    @posts = Post.needs_moderation.order(created_at: :desc).page(params[:posts_page]).per(50)
    @replies = Reply.needs_moderation.order(created_at: :desc).page(params[:replies_page]).per(50)
    @feedback = Feedback.unresolved.order(created_at: :desc).page(params[:replies_page]).per(50)
  end

end
