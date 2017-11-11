class NoticesController < ApplicationController
  before_action :authenticate_user

  def index
    all_notices = current_user.notices.order(created_at: :desc)
    @notices = all_notices.read.page(params[:page])
    unread_notices = all_notices.unread
    @unread = unread_notices.group_by(&:groupable_identifier)
    unread_notices.by_type(:other, :friend_request).each(&:read)
  end

end
