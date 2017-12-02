class BannedUsersController < ApplicationController

  def index
    @users = User.banned
  end

  def show
  end

  def new
  end

  def edit
  end

  def update
  end

  def create
  end

end
