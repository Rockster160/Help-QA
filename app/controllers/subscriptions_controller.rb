class SubscriptionsController < ApplicationController
  before_action :authenticate_user

  def index
    @subscriptions = current_user.subscriptions.joins(:post).subscribed.order(created_at: :desc).page(params[:page])
    @unsubscriptions = current_user.subscriptions.joins(:post).unsubscribed.order(unsubscribed_at: :desc).page(params[:unsubbed_page])
  end

  def subscribe
    subscriptions = current_user.subscriptions.where(post_id: params[:subscribe])
    subscriptions.update_all(unsubscribed_at: nil)
    redirect_to account_subscriptions_path
  end

  def unsubscribe
    subscriptions = current_user.subscriptions.where(post_id: params[:unsubscribe])
    subscriptions.update_all(unsubscribed_at: DateTime.current)
    redirect_to account_subscriptions_path
  end

  def destroy
    subscription = Subscription.find(params[:id])

    if subscription.update(unsubscribed: true)
      redirect_to account_subscriptions_path, notice: "You have been unsubscribed from that post. You will no longer receive replies for it."
    else
      redirect_to account_subscriptions_path, alert: "Faield to unsubscribe you. Please try again."
    end
  end

end
