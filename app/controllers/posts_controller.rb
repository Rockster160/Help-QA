class PostsController < ApplicationController
  include ApplicationHelper
  include PostsHelper
  before_action :authenticate_mod, only: [:mod]

  def index
    @posts = Post.not_closed.displayable(current_user).order(created_at: :desc, id: :desc)
    @posts = @posts.claimed.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def history_redirect
    redirect_to build_filtered_path
  end

  def history
    set_post_filter_params

    @posts = Post.displayable(current_user).order(created_at: :desc, id: :desc)
    @posts = @posts.claimed if @filter_options["claimed"]
    @posts = @posts.unclaimed if @filter_options["unclaimed"]
    @posts = @posts.verified_user if @filter_options["verified"]
    @posts = @posts.unverified_user if @filter_options["unverified"]
    @posts = @posts.no_replies if @filter_options["no-replies"]
    @posts = @posts.more_replies_than(0).less_replies_than_or(16) if @filter_options["some-replies"]
    @posts = @posts.more_replies_than(16).less_replies_than_or(30) if @filter_options["few-replies"]
    @posts = @posts.more_replies_than(30) if @filter_options["many-replies"]
    @posts = @posts.only_adult if @filter_options["adult"]
    @posts = @posts.without_adult if @filter_options["safe"]
    @posts = @posts.closed if @filter_options["closed"]
    @posts = @posts.not_closed if @filter_options["open"]
    @posts = @posts.regex_search(params[:search]) if params[:search].present? && params[:regex_body] == "true"
    @posts = @posts.search_for(params[:search]) if params[:search].present? && params[:regex_body] != "true"

    if params[:by_user].present? && (current_mod? || @filter_options["claimed"])
      if params[:by_user].to_s == params[:by_user].to_i.to_s
        @posts = @posts.where(author_id: params[:by_user])
      else
        @posts = @posts.regex_username(params[:by_user]) if params[:regex_user] == "true"
        @posts = @posts.by_username(params[:by_user]) if params[:regex_user] != "true"
      end
    end

    @posts = @posts.by_tags(@filter_options[:tags]) if @filter_options[:tags].present?
    @posts = @posts.page(params[:page])
  end

  def mod
    post = Post.find(params[:id])

    modded_attrs = {}
    if can?(:post_moderation)
      modded_attrs[:in_moderation] = true if params[:in_moderation].present? && params[:in_moderation] == "true"
      modded_attrs[:in_moderation] = false if params[:in_moderation].present? && params[:in_moderation] == "false"
    end
    if can?(:adult_mark_posts)
      modded_attrs[:marked_as_adult] = true if params[:adult].present? && params[:adult] == "true"
      modded_attrs[:marked_as_adult] = false if params[:adult].present? && params[:adult] == "false"
    end
    if can?(:edit_posts)
      modded_attrs[:closed_at] = DateTime.current if params[:close].present? && params[:close] == "true"
      modded_attrs[:closed_at] = nil if params[:close].present? && params[:close] == "false"
    end
    if can?(:remove_posts)
      modded_attrs[:removed_at] = DateTime.current if params[:remove].present? && params[:remove] == "true"
      modded_attrs[:removed_at] = nil if params[:remove].present? && params[:remove] == "false"
    end

    if post.update(modded_attrs)
      redirect_to post_path(post)
    else
      redirect_to post_path(post), alert: post.errors.full_messages.first || "Failed to save Post. Please try again."
    end
  end

  def show
    @post = Post.find(params[:id])
    return redirect_to root_path, alert: "Sorry, this post has been removed." if @post.removed? && !current_mod?
    if user_signed_in?
      current_user.invites.unread.where(post: @post).each(&:read)
      current_user.notices.subscription.unread.where(post: @post).each(&:read)
      @post.views.create(viewed_by: current_user)
    end
    return authenticate_adult if @post.marked_as_adult? && !current_user&.can_view?(@post)

    @replies = @post.replies.includes_for_display
    @replies = @replies.where("replies.updated_at > ?", Time.at(params[:since].to_i + 1)) if params[:since].present?
    post_edits = @post.post_edits.joins(:acting_user)
    post_edits = post_edits.where("sherlocks.updated_at > ?", Time.at(params[:since].to_i + 1)) if params[:since].present?
    post_edits = post_edits.displayable_post_edits
    invites = @post.post_invites
    invites = invites.where("post_invites.updated_at > ?", Time.at(params[:since].to_i + 1)) if params[:since].present?
    if post_edits.none? && invites.none?
      @replies_with_notifications = @replies
    else
      @replies_with_notifications = [@replies, post_edits, invites].flatten.compact.sort_by(&:created_at)
    end

    if request.xhr?
      render partial: "replies/index", locals: { replies: @replies_with_notifications }
    else
      respond_to do |format|
        format.html
        format.csv { render plain: @post.to_csv }
      end
    end
  end

  def subscribe
    post = Post.find(params[:id])
    subscription = current_user.subscriptions.find_or_create_by(post_id: post.id)

    if subscription.update(unsubscribed_at: true_param?(:subscribe) ? nil : DateTime.current)
      notice_message = if subscription.subscribed?
        "You'll now receive notifications when there are new replies to this post."
      else
        "You'll no longer receive notifications for this post."
      end
      redirect_to post_path(post), notice: notice_message
    else
      redirect_to post_path(post), alert: "Sorry, failed to do that. Please try again."
    end
  end

  def vote
    poll = Post.find(params[:id]).poll
    vote = poll.options.find(params[:option]).votes.create(user: current_user)

    unless vote.persisted?
      flash.now[:alert] = "Failed to vote for Post. Please try again."
    end

    redirect_to post_path(poll.post)
  end

  def edit
    @post = Post.find(params[:id])

    unless current_user&.can_edit_post?(@post)
      redirect_to post_path(@post), alert: "You do not have permission to edit this post."
    end
  end

  def update
    @post = Post.find(params[:id])
    unless current_user&.can_edit_post?(@post)
      return redirect_to post_path(@post), alert: "You do not have permission to edit this post."
    end

    if @post.author == current_user && params[:close] == "true"
      @post.update(closed_at: DateTime.current)
      return redirect_to post_path(@post), notice: "This post has been closed. Please contact a mod if you would like it to be reopened."
    end

    if @post.update(post_params)
      redirect_to post_path(@post)
    else
      flash.now[:alert] = @post.errors.full_messages.first
      render :edit
    end
  end

  def new
    @post = Post.new
  end

  def create
    user = current_user
    user ||= begin
      if !recaptcha_success?
        user = User.new(email: params.dig(:new_user, :email))
        user.errors.add(:base, "Please check the \"I'm not a robot\" checkbox to show that you are not a bot.")
        user
      elsif Post.sounds_like_spam?(params.dig(:post, :body))
        user = User.new(email: params.dig(:new_user, :email))
        user.errors.add(:base, "Your post has been marked as spam. Please avoid links in your first post. If you'd like to ask for help with some external site, try posting a reply with more information.")
        user
      elsif params[:post].blank?
        user = User.new(email: params.dig(:new_user, :email))
        user.errors.add(:base, "Your post looks empty. Please try again.")
        user
      else
        create_and_sign_in_user_by_email(params.dig(:new_user, :email))
      end
    end

    unless user.try(:persisted?)
      return redirect_to new_post_path(post_text: params.dig(:post, :body), anonymous: params.dig(:post, :posted_anonymously), email: user.email), alert: user.errors.full_messages.first || "Something went wrong creating your account. Please make sure you are using a valid email address."
    end

    @post = user.posts.create(post_params)

    if @post.persisted?
      redirect_to post_path(@post), notice: "Successfully created post! While you're waiting for replies, consider viewing other posts and helping others."
    else
      if @post.sounds_like_spam?
        current_user.ignore_sherlock = true
        current_user.destroy
      end
      redirect_to new_post_path(post_text: post_params[:body], anonymous: post_params[:posted_anonymously], email: user.email), alert: @post.errors.full_messages.first || "Something went wrong creating your post. Please make sure our post consists of words."
    end
  end

  private

  def recaptcha_success?
    response = RestClient.post("https://www.google.com/recaptcha/api/siteverify", secret: ENV['HELPQA_RECAPTCHA_SECRET'], response: params["g-recaptcha-response"], remoteip: request.try(:remote_ip))
    JSON.parse(response)["success"]
  rescue TypeError => e
    false
  rescue JSON::ParserError => e
    false
  end

  def post_params
    params.require(:post).permit(:body, :posted_anonymously, :set_tags)
  end

end
