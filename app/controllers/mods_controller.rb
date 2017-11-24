class ModsController < ApplicationController
  before_action :authenticate_mod

  def show
  end

  def bans
    @banned_users = User.banned.order(updated_at: :desc)
    @banned_ips = BannedIp.current.order(created_at: :desc)
  end

  def queue
    @posts = Post.needs_moderation.order(created_at: :desc).page(params[:posts_page]).per(50)
    @replies = Reply.needs_moderation.order(created_at: :desc).page(params[:replies_page]).per(50)
    @feedback = Feedback.unresolved.order(created_at: :desc).page(params[:replies_page]).per(50)
  end

end
