class TagsController < ApplicationController
  include ApplicationHelper

  def index
  end

  def show
    redirect_to build_history_path
  end

  def redirect
    redirect_to tag_url(params[:tag_name])
  end

end
