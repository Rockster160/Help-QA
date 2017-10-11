class PostsController < ApplicationController
  include ApplicationHelper
  include PostsHelper

  def index
    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def history_redirect
    redirect_to build_filtered_path(path_root: "/history")
  end

  def history
    set_post_filter_params

    @posts = Post.conditional_adult(current_user).order(created_at: :desc)
    @posts = @posts.claimed if @filter_options["claimed"]
    @posts = @posts.unclaimed if @filter_options["unclaimed"]
    @posts = @posts.verified_user if @filter_options["verified"]
    @posts = @posts.unverified_user if @filter_options["unverified"]
    @posts = @posts.no_replies if @filter_options["no-replies"]
    @posts = @posts.more_replies_than(0).less_replies_than_or(16) if @filter_options["some-replies"]
    @posts = @posts.more_replies_than(16).less_replies_than_or(30) if @filter_options["few-replies"]
    @posts = @posts.more_replies_than(30) if @filter_options["many-replies"]
    @posts = @posts.search_for(params[:search]) if params[:search].present?
    @posts = @posts.by_username(params[:by_user]) if params[:by_user].present?
    @posts = @posts.by_tags(@filter_options[:tags]) if @filter_options[:tags].present?
    @posts = @posts.page(params[:page])
  end

  def mod
    post = Post.find(params[:post_id])
    return redirect_to post_path(post) unless current_user.try(:mod?)

    modded_attrs = {}
    modded_attrs[:marked_as_adult] = true if params[:adult].present? && params[:adult] == "true"
    modded_attrs[:marked_as_adult] = false if params[:adult].present? && params[:adult] == "false"
    modded_attrs[:closed_at] = DateTime.current if params[:close].present? && params[:close] == "true"
    modded_attrs[:closed_at] = nil if params[:close].present? && params[:close] == "false"

    if Sherlock.update_by(current_user, post, modded_attrs)
      redirect_to post_path(post)
    else
      redirect_to post_path(post), alert: post.errors.full_messages.first || "Failed to save Post. Please try again."
    end
  end

  def show
    @post = Post.find(params[:id])
    if user_signed_in?
      current_user.invites.unread.where(post_id: @post.id).each(&:read)
      current_user.notices.subscription.unread.where(notice_for_id: @post.id).each(&:read)
    end
    authenticate_adult unless current_user&.can_view?(@post)

    @replies = @post.replies.order(created_at: :asc)
    closed_notifications = Sherlock.closed_notifications_for(@post)
    @replies_with_notifications = [@replies, closed_notifications].flatten.sort_by(&:created_at)
  end

  def vote
    poll = Post.find(params[:post_id]).poll
    vote = poll.options.find(params[:option]).votes.create(user: current_user)

    unless vote.persisted?
      flash.now[:alert] = "Failed to vote for Post. Please try again."
    end

    redirect_to post_path(poll.post)
  end

  def edit
    @post = Post.find(params[:id])

    unless user_signed_in? && (@post.author == current_user || @post.mod? || current_user.can_edit_posts?)
      redirect_to post_path(@post), alert: "You do not have permission to edit this post."
    end
  end

  def update
    @post = Post.find(params[:id])

    if Sherlock.update_by(current_user, @post, post_params)
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def new
  end

  def create
    user = current_user || create_and_sign_in_user_by_email(params.dig(:new_user, :email))

    unless user.try(:persisted?)
      return redirect_to root_path(post_text: post_params[:body], anonymous: post_params[:posted_anonymously]), alert: user.errors.full_messages.first || "Something went wrong creating your account. Please make sure you are using a valid email address."
    end

    @post = user.posts.create(post_params)

    if @post.persisted?
      redirect_to post_path(@post), notice: "Successfully created post! While you're waiting for replies, consider viewing other posts and helping others."
    else
      redirect_to root_path(post_text: post_params[:body], anonymous: post_params[:posted_anonymously], email: user.email), alert: @post.errors.full_messages.first || "Something went wrong creating your post. Please make sure our post consists of words."
    end
  end

  private

  def post_params
    params.require(:post).permit(:body, :posted_anonymously, :set_tags)
  end

end
