class BansController < ApplicationController
  before_action :authenticate_mod

  def new
    render :form
  end

  def create
  end

  def edit
    set_banned_object
    render :form
  end

  def update
    set_banned_object
  end

  def index
    @banned_users = User.banned.order(updated_at: :desc)
    @banned_ips = BannedIp.current.order(created_at: :desc)
  end

  private

  def set_banned_object
    @banned_object = if params[:user].present?
      User.banned.find(params[:user])
    elsif params[:ip].present?
      BannedIp.current.find(params[:ip])
    end
  end
end
