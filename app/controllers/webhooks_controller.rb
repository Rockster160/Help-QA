class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def email
    headers_str = request.headers.map { |k,v| "#{k} ::: #{v}\n" }.join("")
    params_str = params.permit!.to_h.map { |k,v| "#{k} ::: #{v}\n" }.join("")
    CustomLogger.log "\e[32m\nHeaders:\n#{headers_str}\n\e[33m\nParams:\n#{params_str}\n\e[36m\nBody:\n#{request.try(:body).try(:read)}\e[0m"

    # HTTP_X_AMZ_SNS_MESSAGE_TYPE ::: SubscriptionConfirmation
    # HTTP_X_AMZ_SNS_MESSAGE_ID ::: b466304b-daf3-4e19-b70b-bb746ba5379b
    # HTTP_X_AMZ_SNS_TOPIC_ARN ::: arn:aws:sns:us-east-1:213674911845:email-webhook

    head :no_content
  end
end
