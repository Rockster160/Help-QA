class InvitesController < ApplicationController
  before_action :authenticate_user
  after_action :mark_as_read, only: :index

  def index
    @all_invites = current_user.invites.order(created_at: :desc)
    @invites = @all_invites.read.page(params[:page])
    @unread = @all_invites.unread.group_by(&:groupable_identifier)
  end

  private

  def mark_as_read
    @all_invites.unread.each(&:read)
  end

end
