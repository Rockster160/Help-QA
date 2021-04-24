class Devise::User::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    return redirect_to root_path, alert: "Sorry, accounts can not be created in Archive mode. If you need help, or you've landed here by accident, head over to https://help-qa.com to get started." if Rails.env.archive?
    if !recaptcha_success?
      flash.now[:alert] = "Please check the \"I'm not a robot\" checkbox to show that you are not a bot."
      render :new
    elsif params.dig(:user, :password).blank?
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

  private

  def recaptcha_success?
    response = RestClient.post("https://www.google.com/recaptcha/api/siteverify", secret: ENV['HELPQA_RECAPTCHA_SECRET'], response: params["g-recaptcha-response"], remoteip: request.try(:remote_ip))
    JSON.parse(response)["success"]
  rescue TypeError => e
    false
  rescue JSON::ParserError => e
    false
  end

  def user_params
    params.require(:user).permit(:login)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
