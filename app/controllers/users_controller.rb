class UsersController < ApplicationController
  include PostsHelper

  def index
    @users = User.order(created_at: :desc)
    @users = @users.verified if params[:status] == "verified"
    @users = @users.unverified if params[:status] == "unverified"
    @users = @users.search_username(params[:search]) if params[:search].present?
    @users = @users.page(params[:page])
  end

  def update_user_search
    redirect_to users_path(params.permit(:search, :status))
  end

  def show
    @user = User.find(params[:id])
    @recent_posts = @user.posts.claimed.order(created_at: :desc).limit(5)
    @replies = @user.replies.conditional_adult(current_user).claimed.order(created_at: :desc)
  end

  def update
    @user = User.find(params[:id])
    @settings = @user.settings

    if @user.update(user_params)
      redirect_to account_settings_path, notice: "Success!"
    else
      render "settings/index"
    end
  end

  def create
  end

  def add_friend
    friend = User.find(params[:id])
    current_user.add_friend(friend)
    redirect_back fallback_location: user_path(friend)
  end

  def remove_friend
    friend = User.find(params[:id])
    current_user.remove_friend(friend)
    redirect_back fallback_location: user_path(friend)
  end

  private

  def user_params
    params.require(:user).permit(
      :date_of_birth,
      :username,
      :email,
      :password,
      :password_confirmation,
      :send_email_notifications,
      :send_reply_notifications,
      :default_anonymous,
      :friends_only,
      :hide_adult_posts,
      :censor_inappropriate_language
    )
  end

end
