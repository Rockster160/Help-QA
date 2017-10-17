class NoticesController < ApplicationController
  before_action :authenticate_user

  def index
    @unread_only = params[:show].to_s.to_sym == :unread
    @notices = current_user.notices.order(created_at: :desc).page(params[:page])
    @unread = @notices.unread
    @unread.by_type(:other, :friend_request, :friend_approval).each(&:read)
  end

end
