class ShoutsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @shouts = @user.shouts_to.order(created_at: :desc).first(50)
  end

  def shouttrail
    @user = User.find(params[:user_id])
    @other_user = User.find(params[:other_user_id])
    @user.shouts_to.where(sent_from_id: @other_user.id)
    @shouts = Shout.between(@user, @other_user).order(created_at: :desc).first(50)
  end

end
