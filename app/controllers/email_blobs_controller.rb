class EmailBlobsController < ApplicationController
  before_action :authenticate_admin
  before_action :set_filters, only: [:index]

  def search
    redirect_to admin_email_blobs_path(current_filter)
  end

  def show
    @email_blob = EmailBlob.find(params[:id])
    @email_blob.read
  end

  private

  def current_filter
    @current_filter ||= begin
      params.permit(:from, :to, :text).to_h.reject {|k,v|v.blank?}
    end
  end

  def set_filters
    current_filter
    @email_blobs = EmailBlob.order(created_at: :desc).page(params[:page]).per(50)
    @email_blobs = @email_blobs.unread unless params[:status].in?(["all", "read"])
    @email_blobs = @email_blobs.read unless params[:status].in?([nil, "unread", "all"])
    @email_blobs = @email_blobs.where("email_blobs.from ILIKE ?", "%#{params[:from]}%") if params[:from].present?
    @email_blobs = @email_blobs.where("email_blobs.to ILIKE ?", "%#{params[:to]}%") if params[:to].present?
    @email_blobs = @email_blobs.where("email_blobs.text ILIKE ?", "%#{params[:text]}%") if params[:text].present?
  end
end
