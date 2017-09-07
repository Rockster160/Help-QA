class TagsController < ApplicationController

  def index
  end

  def show
  end

  def redirect
    redirect_to tag_url(params[:tag_name])
  end

end
