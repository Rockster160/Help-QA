class RepliesController < ApplicationController

  def index
    @replies = Reply.order(created_at: :desc)
    @replies = @replies.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def create
    user = create_and_sign_in_user_by_email(params.dig(:new_user, :email)) unless user_signed_in?

    if user_signed_in?
      post = Post.find(params[:post_id])
      reply = post.replies.create(reply_params.merge(author: current_user))
      @errors = reply.errors.full_messages
    else
      @errors = user.try(:errors).try(:full_messages) || "Failed to submit Reply."
    end

    if @errors.none? && reply.persisted?
      post.notify_subscribers # Don't notify the current user, since they are the one that made the post...

      subscription = Subscription.find_or_create_by(user_id: current_user.id, post_id: post.id)
      current_user.notices.subscriptions.create if subscription.try(:subscribed?)
    end

    respond_to do |format|
      format.json { render json: {errors: @errors} }
      format.html { redirect_to post_path(post) }
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
