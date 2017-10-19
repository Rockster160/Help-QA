module ActionMailer
  class Base
    prepend_view_path 'app/views/mailers'

    after_action :check_deliverability

    private

    def check_deliverability
      puts "#{@_message.body.raw_source}" if Rails.env.development?
      return if self.class.to_s.include?("Devise")
      mail_to = @_message.to.try(:first)
      mail_to_user = User.where(email: mail_to).first
      if mail_to.present? && mail_to_user.present?
        mail.perform_deliveries = !mail_to_user.settings.send_email_notifications?
      end
    end
  end
end
