class IndexController < ApplicationController

  def index
    @currently_popular_post = Post.all.sample
    @recent_members = User.order_by_last_online.first(20)
    @recent_posts = Post.order(created_at: :desc).first(10)
    @current_tags = Tag.where(id: @recent_posts.map(&:tag_ids).flatten.uniq).count_order.first(5)
    @global_tags = Tag.count_order.first(5)
  end

end
