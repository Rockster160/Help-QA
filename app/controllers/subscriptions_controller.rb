class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subscriptions = current_user.subscriptions.order(created_at: :desc).page(params[:page])
  end

  def destroy
    subscription = Subscription.find(params[:id])

    if subscription.destroy
      redirect_to account_subscriptions_path, notice: "You have been unsubscribed from that post. You will no longer receive replies for it."
    else
      redirect_to account_subscriptions_path, alert: "Faield to unsubscribe you. Please try again."
    end
  end

end
