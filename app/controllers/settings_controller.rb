class SettingsController < ApplicationController

  def index
    @settings = current_user.settings || current_user.create_settings
  end

  def update
    @settings = current_user.settings

    if @settings.update(user_settings_params)
      redirect_to account_settings_path, notice: "Successfully updated settings!"
    else
      redirect_to account_settings_path, notice: "Failed to update settings. Please try again."
    end
  end

  private

  def user_settings_params
    params.require(:user_setting).permit(*@settings.editable_properties)
  end

end
