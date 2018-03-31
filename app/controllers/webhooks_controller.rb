class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def email
    headers_str = request.headers.map { |k,v| "#{k} ::: #{v}\n" }.join("")
    params_str = params.permit!.to_h.map { |k,v| "#{k} ::: #{v}\n" }.join("")
    body_str = request.try(:body).try(:read)
    # CustomLogger.log "\e[32m\nHeaders:\n#{headers_str}\n\e[33m\nParams:\n#{params_str}\n\e[36m\nBody:\n#{body_str}\e[0m"

    EmailBlob.create(blob: "#{body_str}")

    # HTTP_X_AMZ_SNS_MESSAGE_TYPE ::: SubscriptionConfirmation
    # HTTP_X_AMZ_SNS_MESSAGE_ID ::: b466304b-daf3-4e19-b70b-bb746ba5379b
    # HTTP_X_AMZ_SNS_TOPIC_ARN ::: arn:aws:sns:us-east-1:213674911845:email-webhook

    # HTTP_X_AMZ_SNS_MESSAGE_TYPE ::: Notification
    # HTTP_X_AMZ_SNS_MESSAGE_ID ::: e09432c2-cbf0-55b1-b2fa-61f64ce90784
    # HTTP_X_AMZ_SNS_TOPIC_ARN ::: arn:aws:sns:us-east-1:833466556696:email-webhook
    # HTTP_X_AMZ_SNS_SUBSCRIPTION_ARN ::: arn:aws:sns:us-east-1:833466556696:email-webhook:9a1d9c55-c4a7-41fa-9b4a-a78e8cafd73a

    head :no_content
  end
end
