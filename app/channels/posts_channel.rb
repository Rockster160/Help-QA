class PostsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{params[:channel_id]}"
  end
end
