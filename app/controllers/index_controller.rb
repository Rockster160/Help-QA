class IndexController < ApplicationController

  def index
    @global_tags = []
    @current_tags = []
    @currently_popular_post = Rando.posts(1).first
    @recent_members = Rando.people(25).sort { |u1, u2| u2.last_login_at <=> u1.last_login_at }
    @recent_posts = Rando.posts(10).sort { |p1, p2| p2.created_at <=> p1.created_at }
  end

end
