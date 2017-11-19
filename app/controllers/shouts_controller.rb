class ShoutsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @shouts = @user.shouts_to.displayable.order(created_at: :desc).first(50)
    @shouts_from = User.not_banned.joins(:shouts_from)
      .where(shouts: { sent_to_id: @user.id })
      .group("users.id")
      .order("MAX(shouts.created_at) DESC")
      .limit(50)

    if @user == current_user
      @user.shouts.unread.each(&:read)
    end
  end

  def shouttrail
    @user = User.find(params[:user_id])
    @other_user = User.find(params[:other_user_id])
    @user.shouts_to.displayable.where(sent_from_id: @other_user.id)
    @shouts = Shout.between(@user, @other_user).order(created_at: :desc).first(50)

    if @user == current_user
      @user.shouts_to.unread.where(sent_from_id: @other_user.id).each(&:read)
    elsif @other_user == current_user
      @other_user.shouts_to.unread.where(sent_from_id: @user.id).each(&:read)
    end
  end

  def create
    @user = User.find(params[:user_id])
    @shout = Sherlock.update_by(current_user, @user.shouts_to.new, {body: params[:shout][:body], sent_from_id: current_user.id})

    if @shout.persisted?
      redirect_to user_shouttrail_path(current_user, @user)
    else
      redirect_to user_shouttrail_path(current_user, @user), alert: "No matter how loud you shout it, nobody will hear if you say nothing."
    end
  end

  def destroy
    shout = Shout.find(params[:id])
    Sherlock.update_by(current_user, shout, {removed_at: DateTime.current})
    redirect_back fallback_location: user_shouts_path(shout.sent_to)
  end

end
