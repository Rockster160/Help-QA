class DeviseOverrideMailer < Devise::Mailer
  def confirmation_instructions(record, token, options={})
    if record.pending_reconfirmation?
      options[:template_name] = 'reconfirmation_instructions'
    else
      options[:template_name] = 'confirmation_instructions'
    end
    super
  end
end
