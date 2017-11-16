class StaticPagesController < ApplicationController

  def one_time_donation
    Stripe.api_key = ENV["HELPQA_STRIPE_SECRET"]

    begin
      charge = Stripe::Charge.create(
        amount: (params[:amount].to_f * 100).round,
        currency: params[:currency],
        description: params[:description],
        source: params[:stripeToken]
      )
    rescue Stripe => e
      SlackNotifier.notify("Stripe failed to charge: \n>>> #{e.inspect}")
      return redirect_to donate_path, alert: "Sorry, something when wrong submitting your donation. It was not submitted properly."
    end
    redirect_to root_path, notice: "Thank you for your donation! We appreciate it immensely."
  end

end
