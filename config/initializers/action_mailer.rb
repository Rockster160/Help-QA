module ActionMailer
  class Base
    prepend_view_path 'app/views/mailers'

    after_action :check_deliverability
    helper_method :attach_auth_token_to_url

    def attach_auth_token_to_url(url)
      return url unless url.present? && @user.present?
      uri = URI.parse(url)
      new_query_uri = URI.decode_www_form(uri.query || '') << ["auth", @user.auth_token]
      uri.query = URI.encode_www_form(new_query_uri)
      uri.to_s
    end

    private

    def check_deliverability
      puts "#{@_message.body.raw_source}" if Rails.env.development?
      return if self.class.to_s.include?("Devise")
      mail_to = @_message.to.try(:first)
      mail_to_user = User.where(email: mail_to).first
      if mail_to.present? && mail_to_user.present?
        mail.perform_deliveries = mail_to_user.settings.send_email_notifications?
      end
    end
  end
end
