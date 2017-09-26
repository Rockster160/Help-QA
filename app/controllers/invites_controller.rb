class InvitesController < ApplicationController
  before_action :authenticate_user!

  def index
    @unread_only = params[:show].to_s.to_sym == :unread
    @invites = current_user.invites.order(created_at: :desc).page(params[:page])
    @invites = @invites.unread if @unread_only
  end

end
