class ModsController < ApplicationController
  include AuditHelper

  def queue
    @posts = Post.needs_moderation.order(created_at: :desc).page(params[:posts_page]).per(50)
    @replies = Reply.needs_moderation.order(created_at: :desc).page(params[:replies_page]).per(50)
    @feedback = Feedback.unresolved.order(created_at: :desc).page(params[:replies_page]).per(50)
  end

  def audit_redirect
    redirect_to build_filtered_path
  end

  def audit
    set_audit_filters
  end

end
