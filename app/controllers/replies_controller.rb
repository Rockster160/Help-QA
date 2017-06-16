class RepliesController < ApplicationController

  def index
    @replies = Reply.order(created_at: :desc)
    @replies = @replies.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def create
    @post = Post.find(params[:post_id])
    @reply = @post.replies.create(reply_params.merge(author: current_user))
    @post.notify_subscribers
    subscription = Subscription.find_or_create_by(user_id: current_user.id, post_id: @post.id)
    if subscription.try(:subscribed?)
      current_user.notices.subscriptions.create
    end

    respond_to do |format|
      format.json { render json: reply }
      format.html { render :show, layout: !request.xhr? }
    end
  end

  private

  def reply_params
    params.require(:reply).permit(
      :body,
      :posted_anonymously
    )
  end

end
