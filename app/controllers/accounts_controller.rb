class AccountsController < ApplicationController
  before_filter :authenticate_user!, except: [ :confirm, :confirmation ]
  before_filter :athenticate_confirmation_token!, only: [ :confirm, :confirmation ]

  def confirmation
    if @user.confirm_with_password(user_params)
      sign_in(@user)
      redirect_to edit_account_path
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
      :password_confirmation
    )
  end

  def athenticate_confirmation_token!
    confirmation_token = params[:confirmation_token] || params.dig(:user, :confirmation_token)
    redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless confirmation_token.present?
    @user = User.find_by(confirmation_token: confirmation_token)
    redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless @user.present?
  end

end
