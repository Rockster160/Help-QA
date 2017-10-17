class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  append_view_path Rails.root.join("app", "views", "mailers")
  default from: "\"HelperNow\" <helpernowcontact@gmail.com>"
end
