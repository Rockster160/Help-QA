class RepliesController < ApplicationController
  include LinkPreviewHelper
  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :logit, only: [:meta]

  def index
    if Rails.env.archive? && params[:user_id].nil?
      @replies = Reply.none.page(0)
      flash.now[:alert] = "Sorry, we're unable to load all replies at once. In order to search replies, please filter the replies by opening through a user or specific post."
      return
    end
    @replies = Reply.not_helpbot.displayable(current_user).order(created_at: :desc, id: :desc).page(params[:page]).per(10)
    @replies = @replies.claimed.where(author_id: params[:user_id]) if params[:user_id].present?
    @replies = @replies.by_fuzzy_text(params[:by_fuzzy_text]) if params[:by_fuzzy_text].present?
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end

  def create
    request_acceptance unless user_signed_in?
    return unless user_signed_in?

    @user = current_user
    @post = Post.find(params[:post_id])

    create_or_update_reply
    flash_hash = @errors.any? ? {alert: @errors.first} : {}

    respond_to do |format|
      format.json { render json: {errors: @errors} }
      format.html { redirect_to post_path(@post), flash_hash }
    end
  end

  def mod
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])
    was_new = reply.created_at == reply.updated_at
    was_moderated = reply.in_moderation?
    reply.touch # Trigger an update so it doesn't appear as a new object.

    modded_attrs = {}
    modded_attrs[:in_moderation] = true if true_param?(:in_moderation)
    modded_attrs[:in_moderation] = false if false_param?(:in_moderation) || true_param?(:remove) || true_param?(:adult)
    modded_attrs[:marked_as_adult] = true if true_param?(:adult)
    modded_attrs[:marked_as_adult] = false if false_param?(:adult)
    modded_attrs[:removed_at] = DateTime.current if true_param?(:remove)
    modded_attrs[:removed_at] = nil if false_param?(:remove)

    if reply.update(modded_attrs)
      reply.send(:notify_subscribers) if was_new && was_moderated && !reply.in_moderation? && !reply.removed?
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
      format.json { render json: generate_previews_for_urls }
    end
  end

  private

  def create_or_update_reply
    if user_signed_in?
      if params[:id].present?
        reply = @post.replies.find(params[:id])
        if current_user.can_edit_reply?(reply)
          reply.update(reply_params)
          @errors = reply.errors.full_messages
        else
          @errors = ["You do not have permission to edit this reply."]
        end
      else
        reply = @post.replies.create(reply_params.merge(author: current_user))
        @errors = reply.errors.full_messages
      end
    else
      @errors = @user.try(:errors).try(:full_messages) || ["Failed to submit Reply."]
    end
  end

  def reply_params
    params.require(:reply).permit(
      :body,
      :posted_anonymously
    )
  end

end
