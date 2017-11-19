class UsersController < ApplicationController
  include PostsHelper
  before_action :authenticate_mod, only: [:moderate]

  def index
    @users = User.displayable.order(created_at: :desc)
    @users = @users.verified if params[:status] == "verified"
    @users = @users.unverified if params[:status] == "unverified"
    @users = @users.search_username(params[:search]) if params[:search].present?
    @users = @users.search_ip(params[:ip_search]) if current_mod? && params[:ip_search].present?
    @users = @users.page(params[:page])
  end

  def update_user_search
    redirect_to users_path(params.permit(:search, :status, :ip_search))
  end

  def show
    @user = User.find(params[:id])
    return render :banned if @user.banned?
    @recent_posts = @user.posts.claimed.order(created_at: :desc).limit(5)
    @top_replies = @user.replies.claimed.favorited.order(favorite_count: :desc, created_at: :desc)
    @replies = @user.replies.displayable(current_user).claimed.order(created_at: :desc)
  end

  def update
    @user = current_user
    @settings = @user.settings
    sign_in_again = current_user == @user
    did_update_age = params.dig(:user, :date_of_birth).present?

    if Sherlock.update_by(current_user, @user, user_params).persisted?
      if did_update_age && @user.age.nil?
        flash.now[:alert] = "Your birthday must match the format MM/DD/YYYY"
        render "settings/index"
      else
        bypass_sign_in(@user) if sign_in_again
        @user.delay.deliver_confirmation_email if user_params[:email].present?
        redirect_to account_settings_path, notice: "Success!"
      end
    else
      flash.now[:alert] ||= "Failed to update your account settings."
      render "settings/index"
    end
  end

  def moderate
    @user = User.find(params[:id])

    if Sherlock.update_by(current_user, @user, moderatable_params).persisted?
      redirect_to @user, notice: "Success!"
    else
      redirect_to @user, alert: "Failed to make changes."
    end
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
      :password_confirmation
    )
  end

  def moderatable_params
    moderatable_attrs = {}
    moderatable_attrs[:banned_until] = case params[:ban].to_s.to_sym
    when :none then 1.second.ago
    when :day then 1.day.from_now
    when :week then 1.week.from_now
    when :month then 1.month.from_now
    when :permanent then 100.years.from_now
    end
    moderatable_attrs[:can_use_chat] = false if params[:revoke].to_s == "chat"
    moderatable_attrs[:can_use_chat] = true if params[:grant].to_s == "chat"
    if params[:ban].to_s.to_sym == :ip
      ip_bans = BannedIp.where(ip: @user.current_sign_in_ip || @user.last_sign_in_ip)
      if ip_bans.any?
        ip_bans.destroy_all
      else
        ip_bans.create
      end
    end
    moderatable_attrs.delete_if { |k, v| v.blank? && v != false }
  end

end
