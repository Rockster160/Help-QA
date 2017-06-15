class RepliesController < ApplicationController

  def index
    @replies = Reply.order(created_at: :desc)
    @replies = @replies.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

end
