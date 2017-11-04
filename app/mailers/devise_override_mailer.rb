class DeviseOverrideMailer < Devise::Mailer
  def confirmation_instructions(record, token, options={})
    return
  end
end
