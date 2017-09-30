class RepliesController < ApplicationController

  def index
    @replies = Reply.order(created_at: :desc).page(params[:page]).per(10)
    @replies = @replies.claimed.where(author_id: params[:user_id]) if params[:user_id].present?
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end

  def create
    user = create_and_sign_in_user_by_email(params.dig(:new_user, :email)) unless user_signed_in?
    post = Post.find(params[:post_id])

    if user_signed_in?
      reply = post.replies.create(reply_params.merge(author: current_user))
      @errors = reply.errors.full_messages
    else
      @errors = user.try(:errors).try(:full_messages) || "Failed to submit Reply."
    end

    respond_to do |format|
      format.json { render json: {errors: @errors} }
      format.html { redirect_to post_path(post) }
    end
  end

  def favorite
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])
    favorited = current_user.favorite_replies.create(reply: reply, post: post)

    if favorited.persisted?
      redirect_to post_path(post, anchor: "reply-#{reply.id}")
    else
      redirect_to post_path(post, anchor: "reply-#{reply.id}"), alert: favorited.errors.full_messages.first || "Failed to save favorite. Please try again."
    end
  end

  def unfavorite
    post = Post.find(params[:post_id])
    reply = post.replies.find(params[:reply_id])
    favorited = current_user.favorite_replies.find_by(reply: reply, post: post)

    if favorited.destroy
      redirect_to post_path(post, anchor: "reply-#{reply.id}")
    else
      redirect_to post_path(post, anchor: "reply-#{reply.id}"), alert: favorited.errors.full_messages.first || "Failed to save favorite. Please try again."
    end
  end

  def meta
    meta_data = Rails.cache.fetch(params[:url]) do
      puts "Running Cache Fetch for: #{params[:url]}".colorize(:yellow)
      res = RestClient.get(params[:url])
      doc = Nokogiri::HTML(res.body)
      only_image = MIME::Types.type_for(params[:url]).first.try(:content_type)&.starts_with?("image")

      tags = {}
      doc.search("meta").each do |meta_tag|
        meta_type = meta_tag["property"].presence || meta_tag["name"].presence
        next unless meta_type.present?

        tags[meta_type] = meta_tag["content"]
      end
      favicon_element = doc.xpath('//link[@rel="shortcut icon"]').first

      video_url = tags["twitter:player"]
      iframe_video_url = video_url if video_url.present? && (video_url.include?("player.vimeo") || video_url.include?("youtube.com/embed"))
      iframe_video_url ||= params[:url] if params[:url].present? && (params[:url].include?("player.vimeo") || params[:url].include?("youtube.com/embed"))
      iframe_video_url ||= "https://player.vimeo.com/video/#{params[:url][/\d+$/]}" if params[:url] =~ /vimeo.com\/\d+$/

      pp meta_data = {
        iframe_video_url: iframe_video_url,
        video_url: iframe_video_url.presence || video_url.presence,
        only_image: only_image,
        url: params[:url],
        favicon: favicon_element.present? ? favicon_element["href"] : nil,
        title: doc.title,
        description: tags["twitter:description"].presence || tags["twitter:title"].presence || tags["og:description"].presence || tags["og:title"].presence || tags["description"].presence,
        image: tags["twitter:image"].presence || tags["og:image"].presence || tags["image"].presence,
      }

      meta_data
    end

    render partial: "layouts/link_preview", locals: meta_data
  end

  private

  def reply_params
    params.require(:reply).permit(
      :body,
      :posted_anonymously
    )
  end

end
