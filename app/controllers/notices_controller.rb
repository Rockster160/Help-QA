class NoticesController < ApplicationController
  before_action :authenticate_user

  def index
    @all_notices = current_user.notices.order(created_at: :desc)
    @notices = @all_notices.read.page(params[:page])
    @unread = @all_notices.unread.group_by(&:groupable_identifier)
  end

  def mark_all_read
    current_user.notices.unread.each(&:read)

    redirect_to account_notices_path
  end

end
