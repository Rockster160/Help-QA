class InvitesController < ApplicationController
  before_action :authenticate_user

  def index
    @all_invites = current_user.invites.order(created_at: :desc)
    @invites = @all_invites.read.page(params[:page])
    @unread = @all_invites.unread.group_by(&:groupable_identifier)
  end

  def mark_all_read
    current_user.invites.unread.each(&:read)

    redirect_to account_invites_path
  end

end
