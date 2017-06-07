class PostsController < ApplicationController

  def index
  end

  def show
    @post = Post.find(params[:id])
    @replies = @post.replies.order(created_at: :asc)
  end

  def edit
  end

  def update
  end

  def new
  end

  def create
  end

end
