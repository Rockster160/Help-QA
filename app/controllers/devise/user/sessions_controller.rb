class Devise::User::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    return redirect_to root_path, alert: "Sorry, accounts can not be created in Archive mode." if Rails.env.archive?
    if params.dig(:user, :password).blank?
      @user = User.find_for_database_authentication(user_params)
      if @user.nil?
        @user = User.create(email: user_params[:login])
        sign_in(@user) if @user.persisted?
      elsif @user.unconfirmed? || @user.deactivated?
        @user.send_confirmation_email
      else
        @user.send_reset_password_instructions
      end
      redirect_to root_path, notice: "You should receive instructions to your email on file assisting you in logging in.\nBe sure to check your spam filter."
    else
      super
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  def user_params
    params.require(:user).permit(:login)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
