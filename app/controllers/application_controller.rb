class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_action :deactivate_user, :see_current_user, :logit, :preload_emojis

  def flash_message
    flash.now[params[:flash_type].to_sym] = params[:message]
    render partial: 'layouts/flashes'
  end

  private

  def reload_emoji_cache
    Rails.cache.delete("emoji_list")
    Rails.cache.delete("emoji_names")
    Rails.cache.delete("emoji_loader")
  end

  def preload_emojis
    @emoji_list = Rails.cache.fetch("emoji_list") { JSON.parse(File.read("lib/emoji.json")) }
    @emoji_names = Rails.cache.fetch("emoji_names") { @emoji_list.keys }
  end

  def deactivate_user
    if user_signed_in? && current_user.deactivated?
      current_user.send_confirmation_instructions
      sign_out :user
      flash.now[:notice] = nil
      flash.now[:alert] = "Your account has been deactivated! Please click the link we sent to your email address to activate your account."
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
      redirect_to new_user_registration_path, alert: "Please verify your age before continuing."
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

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password])
  end

end
