class ProfileController < ApplicationController
  before_action { @user = current_user; @profile = @user.profile }

  def update
    if @profile.update(profile_params)
      redirect_to user_path(@user), notice: "Successfully updated Bio!"
    else
      render :index
    end
  end

  private

  def profile_params
    params.require(:user_profile).permit(@profile.editable_attributes.keys)
  end
end
