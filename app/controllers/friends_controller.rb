class FriendsController < ApplicationController
  before_action :authenticate_user

  def index
    @friends = current_user.friends.order(last_seen_at: :desc)
    @fans = current_user.fans.order(last_seen_at: :desc)
    @favorites = current_user.favorites.order(last_seen_at: :desc)
  end

  def update
    friend = User.find(params[:id])
    current_user.add_friend(friend)
    redirect_to account_friends_path
  end

  def destroy
    friend = User.find(params[:id])
    current_user.remove_friend(friend)
    redirect_to account_friends_path
  end

end
