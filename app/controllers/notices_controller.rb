class NoticesController < ApplicationController
  before_action :authenticate_user

  def index
    all_notices = current_user.notices.order(created_at: :desc)
    @notices = all_notices.read.page(params[:page])
    @unread = all_notices.unread
    @unread.by_type(:other, :friend_request).each(&:read)
    @unread = @unread.group_by(&:groupable_identifier)
  end

end
