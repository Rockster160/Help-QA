class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @recent_posts = @user.posts.order(created_at: :desc).limit(5)
    @replies = @user.replies.order(created_at: :desc)
  end

  def edit
  end

  def update
  end

  def new
  end

  def create
  end

end
