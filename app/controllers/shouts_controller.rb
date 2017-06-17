class ShoutsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @shouts = @user.shouts_to.order(created_at: :desc).first(50)
    @shouts_from = User.joins(:shouts_from)
      .where(shouts: { sent_to_id: @user.id })
      .group("users.id")
      .order("MAX(shouts.created_at) DESC")

    if @user == current_user
      @user.notices.unread.shouts.each(&:read!)
    end
  end

  def shouttrail
    @user = User.find(params[:user_id])
    @other_user = User.find(params[:other_user_id])
    @user.shouts_to.where(sent_from_id: @other_user.id)
    @shouts = Shout.between(@user, @other_user).order(created_at: :desc).first(50)

    if @user == current_user
      @user.notices.unread.where(notice_for_id: @shouts.pluck(:id)).shouts.each(&:read!)
    elsif @other_user == current_user
      @other_user.notices.unread.where(notice_for_id: @shouts.pluck(:id)).shouts.each(&:read!)
    end
  end

  def create
    @user = User.find(params[:user_id])
    @shout = @user.shouts_to.create(body: params[:shout][:body], sent_from_id: current_user.id)

    redirect_to user_shouttrail(@user, current_user)
  end

end
