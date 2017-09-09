class PostsController < ApplicationController
  include ApplicationHelper

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
    @posts = @posts.page(params[:page]).per(2) # FIXME: Remove per
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
    filter_values = params.permit(:claimed_status, :reply_count, :user_status, :tags, :page, :new_tag).values

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
      if @filter_options.keys.include?(filter_val)
        @filter_options[filter_val] = true
      else
        @filter_options[:tags] ||= []
        @filter_options[:tags] += filter_val.split(",").map(&:squish)
      end
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
    @filter_params[:tags] = @filter_options[:tags] if @filter_options[:tags].present?
  end

end
