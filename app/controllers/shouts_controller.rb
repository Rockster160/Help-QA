class ShoutsController < ApplicationController
  before_action :authenticate_mod, only: [:show]

  def show
    shout = Shout.find(params[:id])
    redirect_to user_shouttrail_path(shout.sent_from, shout.sent_to, shout_id: params[:id], anchor: "shout-#{shout.id}")
  end

  def index
    @user = User.find(params[:user_id])
    @shouts = @user.shouts_to.displayable.order(created_at: :desc, id: :desc).first(50)
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
    @user, @other_user = @other_user, @user if @other_user == current_user
    find_shouts

    if @user == current_user
      @user.shouts_to.unread.where(sent_from_id: @other_user.id).each(&:read)
    elsif @other_user == current_user
      @other_user.shouts_to.unread.where(sent_from_id: @user.id).each(&:read)
    end
  end

  def create
    @user = User.find(params[:user_id])
    @shout = @user.shouts_to.create(body: params[:shout][:body], sent_from_id: current_user.id)

    if @shout.persisted?
      redirect_to user_shouttrail_path(current_user, @user)
    else
      redirect_to user_shouttrail_path(current_user, @user), alert: "No matter how loud you shout it, nobody will hear if you say nothing."
    end
  end

  def update
    @shout = Shout.find(params[:id])
    return redirect_back(fallback_location: user_shouts_path(@shout.sent_to)) unless current_mod? || current_user == @shout.sent_from

    @shout.update(shout_params)
    redirect_to user_shouttrail_path(@shout.sent_from, @shout.sent_to)
  end

  def destroy
    shout = Shout.find(params[:id])
    shout.update(removed_at: DateTime.current)
    redirect_back fallback_location: user_shouts_path(shout.sent_to)
  end

  private

  def shout_params
    params.require(:shout).permit(:restore, :body)
  end

  def find_shouts
    if params[:shout_id]
      limit = 100
      shout_ids = Shout.between(@user, @other_user).order(created_at: :desc, id: :desc).pluck(:id)
      shout_idx = shout_ids.index(params[:shout_id].to_i)
      min_idx = [shout_idx - (limit / 2), 0].max
      max_idx = [shout_idx + (limit / 2), shout_ids.length - 1].min
      focused_shout_ids = shout_ids[min_idx..max_idx]
      @shouts = Shout.includes(:sent_from, :sent_to).where(id: focused_shout_ids).order(created_at: :desc, id: :desc)
    else
      @shouts = Shout.displayable.includes(:sent_from, :sent_to).between(@user, @other_user).order(created_at: :desc, id: :desc).first(50)
    end
  end

end
