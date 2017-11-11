class ModsController < ApplicationController

  def queue
    @posts = Post.needs_moderation.order(created_at: :desc).page(params[:posts_page]).per(50)
    @replies = Reply.needs_moderation.order(created_at: :desc).page(params[:replies_page]).per(50)
    @feedback = Feedback.unresolved.order(created_at: :desc).page(params[:replies_page]).per(50)
  end

end
