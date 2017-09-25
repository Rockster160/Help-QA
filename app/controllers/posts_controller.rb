class PostsController < ApplicationController
  include ApplicationHelper
  include PostsHelper

  def index
    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def history_redirect
    redirect_to build_history_path
  end

  def history
    set_filter_params

    @posts = Post.order(created_at: :desc)
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
    @posts = @posts.page(params[:page]).per(2) # FIXME: Remove per
  end

  def show
    @post = Post.find(params[:id])
    @replies = @post.replies.order(created_at: :asc)
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
    render layout: false
  end

  def update
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
    params.require(:post).permit(:body, :posted_anonymously)
  end

end
