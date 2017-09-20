class FeedbacksController < ApplicationController

  def feedback
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user if user_signed_in?

    if @feedback.save
      redirect_to root_path, notice: "Thank you for your feedback. A moderator will review shortly, and if we need to follow up, we will get back to you in a timely manner."
    else
      flash.now[:alert] = "Failed to submit your Feedback. Please fix the problems listed below and try again."
      render :feedback
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :email,
      :body,
      :url
    )
  end

end
