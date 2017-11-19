class ProfileController < ApplicationController
  before_action :authenticate_user
  before_action { @user = current_user; @profile = @user.try(:profile) }

  def update
    if Sherlock.update_by(current_user, @profile, profile_params).persisted?
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
