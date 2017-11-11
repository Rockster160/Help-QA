class AccountsController < ApplicationController
  before_action :authenticate_user, except: [ :confirm, :set_confirmation ]
  before_action :athenticate_confirmation_token!, only: [ :confirm, :set_confirmation ]

  def set_confirmation
    if @user.confirmed?
      if password_matched_confirmation? && @user.update(user_params)
        bypass_sign_in(@user)
        redirect_to edit_account_path, notice: "Thanks for verifying your email!"
      else
        @user.errors.add(:password_confirmation, "must match password.") unless password_matched_confirmation?
        render :confirm
      end
    else
      if @user.confirm_with_password(user_params)
        bypass_sign_in(@user)
        redirect_to edit_account_path, notice: "Thanks for verifying your email!"
      else
        render :confirm
      end
    end
  end

  # We need to define this method here, otherwise the `avatar` helper method in the `ApplicationHelper` gets called
  def avatar
  end

  def notifications
    respond_to do |format|
      format.json { render json: @notifications }
    end
  end

  def update_avatar
    if current_user.update(user_params)
      render :avatar
    else
      redirect_to avatar_account_path, notice: "Successfully updated avatar."
    end
  end

  private

  def password_matched_confirmation?
    return false unless user_params[:password].present?
    user_params[:password] == user_params[:password_confirmation]
  end

  def confirmation_error(msg)
    flash.now[:alert] = msg
    render :confirm
  end

  def user_params
    params.require(:user).permit(
      :current_password,
      :password,
      :password_confirmation,
      :confirmation_token,
      :avatar_image
    )
  end

  def athenticate_confirmation_token!
    return redirect_to root_path, alert: "Your account is already verified." if user_signed_in? && current_user.verified? && current_user.confirmed? && current_user.encrypted_password.present?
    confirmation_token = params[:confirmation_token] || params.dig(:user, :confirmation_token)
    return redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless confirmation_token.present?
    @user = User.find_by(confirmation_token: confirmation_token)
    return redirect_to new_user_session_path, alert: "Invalid token. Please use the link we sent to your email to confirm your account." unless @user.present?

    if @user.encrypted_password.present?
      @user.update(confirmed_at: DateTime.current, verified_at: DateTime.current)
      redirect_to edit_account_path, notice: "Thanks for verifying your email!"
    end
  end

end
