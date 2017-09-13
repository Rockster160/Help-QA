class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_action :see_current_user, :logit

  def flash_message
    flash.now[params[:flash_type].to_sym] = params[:message]
    render partial: 'layouts/flashes'
  end

  private

  def create_and_sign_in_user_by_email(email)
    user = User.create(email: email)
    sign_in(user) if user.persisted?
    user
  end

  def see_current_user
    Rails.logger.silence do
      if user_signed_in?
        current_user.see!
        request.env['exception_notifier.exception_data'] = { current_user: current_user }
      end
    end
  end

  def logit
    # return CustomLogger.log_blip! if params[:checker]
    # CustomLogger.log_request(request, current_user)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password])
  end

end
