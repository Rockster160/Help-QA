class PostsController < ApplicationController

  def index
  end

  def show
    @post = Post.find(params[:id])
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
