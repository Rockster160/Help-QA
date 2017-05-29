class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :see_current_user, :logit

  def flash_message
    flash.now[params[:flash_type].to_sym] = params[:message]
    render partial: 'layouts/flashes'
  end

  private

  def see_current_user
    Rails.logger.silence do
      # if user_signed_in?
      #   current_user.see!
      #   request.env['exception_notifier.exception_data'] = { current_user: current_user }
      # end
    end
  end

  def logit
    # return CustomLogger.log_blip! if params[:checker]
    # CustomLogger.log_request(request, current_user)
  end

end
