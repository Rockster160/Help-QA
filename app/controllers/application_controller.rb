class ApplicationController < ActionController::Base
  include ApplicationHelper
  prepend_before_action :unauth_bad_requests
  before_action :auto_sign_in
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_action :unauth_banned_user, :deactivate_user, :see_current_user, :logit, :preload_emojis, :set_notifications, :set_theme
  skip_before_action :logit, only: [:flash_message, :chat_list]
  skip_before_action :logit, if: -> { params[:since].present? }
  helper_method :true_param?, :false_param?
  # around_action :display_request_length, except: [:flash_message, :chat_list]
  # skip_before_action :verify_authenticity_token

  if Rails.env.production?
    rescue_from ActionController::UnknownFormat,     with: :not_found
    rescue_from ActionController::UnknownController, with: :not_found
    rescue_from ActionView::MissingTemplate,         with: :not_found
    rescue_from ActionController::ParameterMissing,  with: :not_found
  end

  def flash_message
    flash.now[params[:flash_type].to_sym] = params[:message].html_safe
    render partial: 'layouts/flashes'
  end

  def form_redirect
    redirect_to Rails.application.routes.recognize_path(params[:path]).merge(params.permit!.except(:path, :commit, :controller, :action))
  end

  private

  def not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def reload_emoji_cache
    Rails.cache.delete("emoji_list")
    Rails.cache.delete("emoji_names")
    ActionController::Base.new.expire_fragment("emoji_loader")
    # ActionController::Base.new.expire_fragment("invite_loader")
  end

  def preload_emojis
    # reload_emoji_cache
    @emoji_list = Rails.cache.fetch("emoji_list") { JSON.parse(File.read("lib/emoji.json")).reject { |emoji, _aliases| emoji.to_s.starts_with?("// ") } }
    @emoji_names = Rails.cache.fetch("emoji_names") { @emoji_list.keys }
  end

  def set_notifications
    return unless user_signed_in?
    @notifications = {
      notices: current_user.notices.unread.group_by(&:groupable_identifier).count,
      shouts: current_user.shouts.unread.count,
      invites: current_user.invites.unread.count
    }
    @notifications.merge!(modq: Post.needs_moderation.count + Reply.needs_moderation.count + Feedback.unresolved.count) if current_mod?
  end

  def unauth_banned_user
    if user_signed_in? && current_user.banned?
      sign_out :user
      flash.now[:notice] = nil
      flash.now[:alert] = "Your account has been banned! Please click the link we sent to your email address to activate your account."
    end
  end

  def deactivate_user
    if user_signed_in? && current_user.deactivated?
      current_user.send_confirmation_email
      sign_out :user
      flash.now[:notice] = nil
      flash.now[:alert] = "Your account has been deactivated! Please click the link we sent to your email address to activate your account."
    end
  end

  def unauthenticated
    redirect_to root_path, alert: "Sorry, you do not have access to this page."
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
      if current_user.age.nil?
        redirect_to account_settings_path, alert: "Please verify your age before continuing."
      elsif current_user.child?
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
      exception_data = {}
      Sherlock.acting_user = current_user
      Sherlock.acting_ip = current_ip_address
      if user_signed_in?
        current_user.see!
        exception_data.merge!({ current_user: current_user })
      end
      Sherlock.exception_data = exception_data
      exception_data.merge!({ params: params.permit!.except(:action, :controller).to_h })
      request.env['exception_notifier.exception_data'] = exception_data
    end
  end

  def auto_sign_in
    if params[:auth].present?
      user = User.find_by(authorization_token: params[:auth])
      if user.present?
        user.confirm unless user.confirmed?
        sign_out :user
        sign_in(user)
      end
    end
  end

  def logit
    return CustomLogger.log_blip! if params[:checker]
    CustomLogger.log_request(request, current_user)
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
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :date_of_birth, :password, :password_confirmation, :current_password])
  end

  def unauth_bad_requests
    head :unauthorized if BannedIp.where(ip: current_ip_address).any?
    head :unauthorized if params[:mode] == "addshout"
  end

  def current_ip_address
    current_user.try(:super_ip) || request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR']
  end

  def true_param?(param_key)
    params[param_key].present? && params[param_key] == "true"
  end

  def false_param?(param_key)
    params[param_key].present? && params[param_key] == "false"
  end

  def set_theme
    return unless params[:theme].present?
    return session.delete(:theme) if params[:theme] == "clear"

    session[:theme] = params[:theme]
  end

  def display_request_length
    t = Time.now.to_f
    yield
    puts "#{params.permit!.to_h}"
    puts "\e[31m#{(Time.now.to_f - t).round(1)} seconds for \e[0m"
  end

end
