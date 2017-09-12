class DeviseOverrideMailer < Devise::Mailer
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, options={})
    if record.pending_reconfirmation?
      options[:template_name] = 'reconfirmation_instructions'
    else
      options[:template_name] = 'confirmation_instructions'
    end
    super
  end
end
