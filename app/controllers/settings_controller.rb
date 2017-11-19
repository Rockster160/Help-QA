class SettingsController < ApplicationController
  before_action :authenticate_user

  def index
    @user = current_user
    @settings = current_user.settings || current_user.create_settings
  end

  def update
    @settings = current_user.settings

    if Sherlock.update_by(current_user, @settings, user_settings_params).persisted?
      redirect_to account_settings_path, notice: "Successfully updated settings!"
    else
      redirect_to account_settings_path, alert: "Failed to update settings. Please try again."
    end
  end

  private

  def user_settings_params
    params.require(:user_setting).permit(
      :hide_adult_posts,
      :censor_inappropriate_language,
      :send_email_notifications,
      :send_reply_notifications,
      :default_anonymous,
      :friends_only
    )
  end

end
