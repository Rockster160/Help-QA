class TagsController < ApplicationController
  include ApplicationHelper
  include PostsHelper

  def index
  end

  def show
    redirect_to build_filtered_path(path_root: "/history")
  end

  def redirect
    redirect_to tag_url(params[:tag_name])
  end

end
