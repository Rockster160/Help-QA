class IndexController < ApplicationController

  def index
    @currently_popular_post = Post.currently_popular
    @recent_friends = User.none
    @recent_friends = current_user.friends.order_by_last_online.limit(20) if user_signed_in?
    @recent_members = User.verified.order_by_last_online.where.not(id: @recent_friends.pluck(:id)).limit(20)
    @recent_posts = Post.order(created_at: :desc).limit(10)
    @current_tags = Tag.where(id: @recent_posts.map(&:tag_ids).flatten.uniq).count_order.limit(5)
    @global_tags = Tag.count_order.limit(5)
  end

end
