class PostsController < ApplicationController

  def index
    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def history
    set_filter_params

    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed if @claimed
    @posts = @posts.unclaimed if @unclaimed
    @posts = @posts.verified_user if @verified_user
    @posts = @posts.unverified_user if @unverified_user
    @posts = @posts.no_replies if @no_replies
    @posts = @posts.more_replies_than(0).less_replies_than(16) if @few_replies
    @posts = @posts.more_replies_than(15) if @many_replies
    @posts = @posts.page(params[:page])#.per(5)
  end

  def show
    @post = Post.find(params[:id])
    @replies = @post.replies.order(created_at: :asc)
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
  end

  private

  def set_filter_params
    filter_values = params.permit(:claimed_status, :reply_count, :user_status, :page).values

    filter_values.each do |filter_val|
      @claimed = true if filter_val == "claimed"
      @unclaimed = true if filter_val == "unclaimed"
      @no_replies = true if filter_val == "no-replies"
      @few_replies = true if filter_val == "few-replies"
      @many_replies = true if filter_val == "many-replies"
      @verified_user = true if filter_val == "verified"
      @unverified_user = true if filter_val == "unverified"
    end
  end

end
