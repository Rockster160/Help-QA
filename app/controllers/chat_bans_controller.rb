class ChatBansController < ApplicationController

  def index
    @users = User.where.not(can_use_chat: true)
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
