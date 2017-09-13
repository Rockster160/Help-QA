class AccountsController < ApplicationController
  before_action :authenticate_user!, except: [ :confirm, :set_confirmation ]
  before_action :athenticate_confirmation_token!, only: [ :confirm, :set_confirmation ]

  def set_confirmation
    if @user.confirm_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to edit_account_path, notice: "Thanks for verifying your email!"
    else
      render :confirm
    end
  end

  private

  def confirmation_error(msg)
    flash.now[:alert] = msg
    render :confirm
  end

  def user_params
    params.require(:user).permit(
      :current_password,
      :password,
      :password_confirmation,
      :confirmation_token
    )
  end

  def athenticate_confirmation_token!
    return redirect_to root_path, alert: "Your account is already verified." if user_signed_in? && current_user.confirmed?
    confirmation_token = params[:confirmation_token] || params.dig(:user, :confirmation_token)
    return redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless confirmation_token.present?
    @user = User.find_by(confirmation_token: confirmation_token)
    redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless @user.present?
  end

end
