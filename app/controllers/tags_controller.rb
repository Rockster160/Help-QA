class TagsController < ApplicationController
  include ApplicationHelper
  include PostsHelper

  def index
  end

  def show
    @tag = Tag.find_by(tag_name: params[:tags]) || Tag.new(tag_name: params[:tags])
  end

  def redirect
    redirect_to tag_url(params[:tag_name])
  end

end
