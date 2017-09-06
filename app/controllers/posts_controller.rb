class PostsController < ApplicationController

  def index
    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def history_redirect
    attached_params = params.permit(:claimed_status, :reply_count, :user_status, :page).values.join("/")
    search_query = params[:search].present? ? "?search=#{params[:search]}" : ""
    redirect_to "#{history_path}/#{attached_params}#{search_query}"
  end

  def history
    set_filter_params

    @posts = Post.order(created_at: :desc)
    @posts = @posts.claimed if @filter_options["claimed"]
    @posts = @posts.unclaimed if @filter_options["unclaimed"]
    @posts = @posts.verified_user if @filter_options["verified-user"]
    @posts = @posts.unverified_user if @filter_options["unverified-user"]
    @posts = @posts.no_replies if @filter_options["no-replies"]
    @posts = @posts.more_replies_than(0).less_replies_than_or(16) if @filter_options["some-replies"]
    @posts = @posts.more_replies_than(16).less_replies_than_or(30) if @filter_options["few-replies"]
    @posts = @posts.more_replies_than(30) if @filter_options["many-replies"]
    @posts = @posts.search_for(params[:search]) if params[:search].present?
    @posts = @posts.page(params[:page]).per(2) # FIXME: Remove per 5
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

    @filter_options = {
      "claimed"      => false,
      "unclaimed"    => false,
      "no-replies"   => false,
      "some-replies" => false,
      "few-replies"  => false,
      "many-replies" => false,
      "verified"     => false,
      "unverified"   => false
    }

    filter_values.each do |filter_val|
      next unless @filter_options.keys.include?(filter_val)
      @filter_options[filter_val] = true
    end

    @filter_params = {}
    @filter_params[:claimed_status] = "claimed" if @filter_options["claimed"]
    @filter_params[:claimed_status] = "unclaimed" if @filter_options["unclaimed"]
    @filter_params[:reply_count] = "no-replies" if @filter_options["no-replies"]
    @filter_params[:reply_count] = "some-replies" if @filter_options["some-replies"]
    @filter_params[:reply_count] = "few-replies" if @filter_options["few-replies"]
    @filter_params[:reply_count] = "many-replies" if @filter_options["many-replies"]
    @filter_params[:user_status] = "verified" if @filter_options["verified"]
    @filter_params[:user_status] = "unverified" if @filter_options["unverified"]
  end

end
