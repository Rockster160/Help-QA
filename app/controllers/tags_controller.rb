class TagsController < ApplicationController
  include ApplicationHelper
  include PostsHelper

  def index
    @tags = Tag.count_order.limit(100)
  end

  def show
    @tags = Tag.by_words(params[:tags].split(","))
    @posts = Post.by_tags(@tags.pluck(:tag_name))
    @users = User.by_tags(@tags.pluck(:tag_name))
  end

  def redirect
    redirect_to tag_url(params[:tag_name])
  end

end
