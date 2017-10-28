class IndexController < ApplicationController

  def index
    @recent_posts = Post.not_banned.conditional_adult(current_user).order(created_at: :desc).limit(10)
    if request.xhr?
      @recent_posts = @recent_posts.where("posts.created_at > ?", Time.at(params[:since].to_i + 1))
      return render partial: "posts/index", locals: { posts: @recent_posts }
    end

    @currently_popular_post = Post.currently_popular
    @recent_friends = User.none
    @recent_friends = current_user.friends.order_by_last_online.limit(20) if user_signed_in?
    @recent_members = User.not_banned.verified.order_by_last_online.where.not(id: @recent_friends.pluck(:id)).limit(20)
    @current_tags = Tag.where(id: @recent_posts.map(&:tag_ids).flatten.uniq).count_order.limit(5)
    @global_tags = Tag.count_order.limit(5)
  end

end
