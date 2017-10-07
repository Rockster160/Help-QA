class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_action :see_current_user, :logit, :preload_emojis

  def flash_message
    flash.now[params[:flash_type].to_sym] = params[:message]
    render partial: 'layouts/flashes'
  end

  private

  def emoji_names
  end

  def preload_emojis
    @emoji_list ||= begin
      emoji_json = JSON.parse(File.read("lib/emoji.json"))
      @emoji_names = emoji_json.keys
      emoji_json
    end
  end

  def authenticate_user
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in before continuing."
    end
  end

  def authenticate_mod
    unless user_signed_in? && current_user.mod?
      redirect_to root_path, alert: "Sorry, you do not have access to this page."
    end
  end

  def authenticate_admin
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "Sorry, you do not have access to this page."
    end
  end

  def authenticate_adult
    if user_signed_in?
      if current_user.child?
        redirect_to root_path, alert: "Sorry, this post contains inappropriate material."
      end
    else
      # FIXME: Redirect to Age Authentication/Sign Up page
      redirect_to root_path, alert: "Sorry, this post contains inappropriate material."
    end
  end

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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password])
  end

end
