class RepliesController < ApplicationController
  include LinkPreviewHelper

  def index
    @replies = Reply.conditional_adult(current_user).order(created_at: :desc).page(params[:page]).per(10)
    @replies = @replies.claimed.where(author_id: params[:user_id]) if params[:user_id].present?
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end

  def create
    is_new_user = !user_signed_in?
    user = create_and_sign_in_user_by_email(params.dig(:new_user, :email)) if is_new_user
    post = Post.find(params[:post_id])

    if user_signed_in?
      reply = post.replies.create(reply_params.merge(author: current_user))
      @errors = reply.errors.full_messages
    else
      @errors = user.try(:errors).try(:full_messages) || "Failed to submit Reply."
    end
    flash_hash = @errors.any? ? {alert: @errors.first} : {}

    additional_data = {}
    if request.xhr? && is_new_user && @errors.none?
      additional_data[:redirect] = post_path(post)
    end

    respond_to do |format|
      format.json { render json: {errors: @errors}.merge(additional_data) }
      format.html { redirect_to post_path(post), flash_hash }
    end
  end

  def mod
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])

    modded_attrs = {has_questionable_text: false}
    modded_attrs[:marked_as_adult] = true if params[:adult].present? && params[:adult] == "true"
    modded_attrs[:marked_as_adult] = false if params[:adult].present? && params[:adult] == "false"
    modded_attrs[:removed_at] = DateTime.current if params[:remove].present? && params[:remove] == "true"
    modded_attrs[:removed_at] = nil if params[:remove].present? && params[:remove] == "false"

    if reply.update(modded_attrs)
      redirect_to post_path(post, anchor: "reply-#{reply.id}")
    else
      redirect_to post_path(post, anchor: "reply-#{reply.id}"), alert: reply.errors.full_messages.first || "Failed to save Reply. Please try again."
    end
  end

  def favorite
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])
    favorited = current_user.favorite_replies.create(reply: reply, post: post)

    if favorited.persisted?
      redirect_to post_path(post, anchor: "reply-#{reply.id}")
    else
      redirect_to post_path(post, anchor: "reply-#{reply.id}"), alert: favorited.errors.full_messages.first || "Failed to save favorite. Please try again."
    end
  end

  def unfavorite
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])
    favorited = current_user.favorite_replies.find_by(reply: reply, post: post)

    if favorited.destroy
      redirect_to post_path(post, anchor: "reply-#{reply.id}")
    else
      redirect_to post_path(post, anchor: "reply-#{reply.id}"), alert: favorited.errors.full_messages.first || "Failed to save favorite. Please try again."
    end
  end

  def meta
    respond_to do |format|
      format.json { render json: generate_previews_for_urls(clear: true) }
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
