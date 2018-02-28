class FeedbacksController < ApplicationController
  before_action :authenticate_mod, only: [:index, :edit, :complete]

  def redirect_all
    redirect_to all_feedback_path(params.permit(:search, :by_user, :resolution_status))
  end

  def index
    @feedbacks = Feedback.order(created_at: :desc, id: :desc).page(params[:page])
    @feedbacks = @feedbacks.resolved if params[:resolution_status].to_s.to_sym == :resolved
    @feedbacks = @feedbacks.unresolved if params[:resolution_status].to_s.to_sym == :unresolved
    @feedbacks = @feedbacks.search_for(params[:search]) if params[:search].present?
    @feedbacks = @feedbacks.by_username(params[:by_user]) if params[:by_user].present?
  end

  def show
    @feedback = Feedback.new
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user if user_signed_in?

    if @feedback.save
      redirect_to root_path, notice: "Thank you for your feedback. A moderator will review shortly, and if we need to follow up, we will get back to you in a timely manner."
    else
      flash.now[:alert] = "Failed to submit your Feedback. Please fix the problems listed below and try again."
      render :show
    end
  end

  def complete
    @feedback = Feedback.find(params[:id])
    @feedback.resolve(current_user)

    redirect_to edit_feedback_path(@feedback)
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
