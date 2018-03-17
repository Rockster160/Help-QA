module Accountable
  extend ActiveSupport::Concern
  include UrlHelper
  RESERVED_WORDS_FOR_USERNAME = ["anonymous", "guest"].freeze

  included do
    before_validation :set_default_username, :set_slug, :set_anonicon_str

    validates_uniqueness_of :username, :slug, message: "Sorry, that Username has already been taken."
    validate :username_meets_requirements?
    validate :at_least_13_years_of_age

    after_create :set_gravatar_if_exists, :create_associated_objects
    after_commit :reset_cache, :deliver_initial_confirmation_email, :broadcast_changes
    after_update :reset_auth_token, if: :encrypted_password_changed?

    scope :banned, -> { where("users.banned_until > ?", DateTime.current) }
  end

  def online?
    return false unless last_seen_at
    last_seen_at > 5.minutes.ago
  end
  def offline?; !online?; end
  def verified?; verified_at?; end
  def medium_term_user?; created_at < 3.months.ago; end
  def long_term_user?; created_at < 1.year.ago; end
  def long_time_user?; long_term_user?; end
  def deactivated?; !verified? && created_at < 1.day.ago; end
  def ip_banned?; BannedIp.where(ip: current_sign_in_ip.presence || last_sign_in_ip).current.any?; end
  def banned?; banned_until? && banned_until > DateTime.current; end
  def perma_banned?; banned? && banned_until > 50.years.from_now; end

  def see!
    update(last_seen_at: DateTime.current)
  end

  def account_completion
    step_data = [
      [:help, :user_confirmation_path, "Confirm account (Verify email and add password)", "Confirm Account - We'll email you a new confirmation email.", verified? && encrypted_password.present?],
      [:help, :account_settings_path, "Update Username", nil, has_updated_username?],
      [:help, :avatar_account_path, "Upload Avatar", nil, avatar_image_file_name.present? || avatar_url.present?],
      [:help, :account_profile_index_path, "Add Bio", nil, profile.about.present?],
      [:help, :new_post_path, "Make your first post", nil, posts.count.positive?],
      [:help, :root_path, "Help somebody (Comment on a post)", nil, replies.joins(:post).where.not(posts: { author_id: id }).count.positive?]
    ]
    steps = {}
    step_data.each do |step|
      icon, url_sym, message, title, completed = *step
      route_params = url_sym == :user_confirmation_path ? {user: {email: email}} : {}
      route = route_for(url_sym, route_params)
      completion_icon = if completed
        ApplicationHelper.hover_icon("check", "complete")
      else
        ApplicationHelper.hover_icon("cross", "incomplete")
      end
      link = ApplicationHelper.hover_icon(icon, title || message, href: route)
      built_message = "#{link} #{completion_icon} #{message}"
      steps[built_message] = completed
    end
    update(completed_signup: true) if !completed_signup? && steps.values.all?
    steps
  end

  def unconfirmed?; !confirmed?; end

  def send_confirmation_instructions
    # Stubbing this method so Devise doesn't send it's own emails
  end

  def deliver_initial_confirmation_email
    return unless created_at == updated_at

    send_confirmation_email
  end

  def send_confirmation_email
    delay.deliver_confirmation_email
  end

  def deliver_confirmation_email
    update(confirmation_sent_at: DateTime.current)
    UserMailer.confirmation_instructions(self).deliver_now
  end

  def ip_address
    location&.update(ip: current_sign_in_ip.presence || last_sign_in_ip) if location.try(:ip).nil?
    super_ip.presence || location.try(:ip).presence || current_sign_in_ip.presence || last_sign_in_ip.presence
  end

  def adult?; age.present? && age >= 18; end
  def child?; !adult?; end
  def age
    return unless date_of_birth.present?
    now = Time.now.utc.to_date
    dob = date_of_birth
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def aka
    previous_usernames = []
    Sherlock.users.where(obj_id: id).each do |sherlock|
      next unless sherlock.new_attributes.keys.include?("username")
      previous_usernames << sherlock.new_attributes["username"]
    end
    previous_usernames.uniq! # No duplicates
    previous_usernames.shift # Remove first (Changes in place)
    previous_usernames - [username] # Remove current
  end

  def email=(new_email)
    if email == new_email && unconfirmed_email.present?
      self.unconfirmed_email = nil
    end
    super
  end

  def date_of_birth=(dob)
    begin
      if dob.is_a?(Date)
        super(dob)
      elsif dob.is_a?(String)
        super(Date.strptime(dob, "%m/%d/%Y"))
      else
        super(Date.parse(dob))
      end
    rescue ArgumentError
      errors.add(:date_of_birth, "was not a valid date. Please be sure to use MM/DD/YYYY format.")
    end
  end

  def gravatar?(options={})
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    options = { rating: "pg", timeout: 2 }.merge(options)
    http = Net::HTTP.new("www.gravatar.com", 80)
    http.read_timeout = options[:timeout]
    response = http.request_head("/avatar/#{hash}?rating=#{options[:rating]}&default=http://gravatar.com/avatar")
    response.code != "302"
  rescue StandardError, Timeout::Error
    false  # Show "no gravatar" if the service is down or slow
  end

  def avatar(size: nil)
    uploaded_url = if avatar_image_file_name.present?
      render_style = case size
      when  0..40  then :tiny
      when 41..100 then :small
      else              :original
      end
      avatar_image.url(render_style)
    end
    uploaded_url.presence || avatar_url.presence || letter.presence || "status_offline.png"
  end

  def to_param
    [id, username.parameterize].join("-")
  end

  def auth_token(force: false)
    return authorization_token if authorization_token.present? && !force
    new_auth_token ||= loop do
      random_token = SecureRandom.hex(20)
      break random_token if User.where(authorization_token: random_token).none?
    end
    update(authorization_token: new_auth_token)
    new_auth_token
  end

  private

  def reset_cache
    # ActionController::Base.new.expire_fragment("invite_loader") if previous_changes.keys.include?("username") || created_at == updated_at
  end

  def broadcast_changes
    ActionCable.server.broadcast("chat", banned: id) if previous_changes["can_use_chat"].present? && !can_use_chat?
  end

  def reset_auth_token
    return if authorization_token_changed?
    auth_token(force: true)
  end

  def set_gravatar_if_exists
    return unless gravatar?
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    update(avatar_url: "https://www.gravatar.com/avatar/#{hash}?rating=pg")
  end

  def set_anonicon_str
    self.anonicon_seed ||= anonicon_seed.presence || ip_address.presence || username.presence || email.presence || id.presence
  end

  def set_default_username
    self.has_updated_username = true if username_changed?
    return if email.blank? || username.present?
    base_username = email.split("@").first
    loop do
      break if base_username.length >= 4
      base_username = "#{base_username}#{base_username}"
    end
    t = 0
    self.username ||= loop do
      try_username = t == 0 ? base_username : "#{base_username}#{t + 1}"
      t += 1
      break try_username if User.where(username: try_username).none?
    end
    username_reserved = RESERVED_WORDS_FOR_USERNAME.include?(self.username.to_s.downcase)
    username_profane = ObscenityChecker.maybe_profane?(self.username)
    if username_reserved || username_profane || self.username.nil?
      self.username = "Guest#{User.count}"
    end
    self.username.try(:squish!)
  end

  def set_slug
    self.slug = username.try(:parameterize)
  end

  def at_least_13_years_of_age
    return unless date_of_birth.present?
    return if age >= 13

    errors.add(:base, "We're sorry- you must be 13 years of age or older to use this site.")
  end

  def create_associated_objects
    build_location(ip: current_sign_in_ip.presence || last_sign_in_ip.presence).save
    build_profile.save
    build_settings.save
  end

  def username_meets_requirements?
    return unless email.present?

    if RESERVED_WORDS_FOR_USERNAME.include?(username.to_s.downcase)
      return errors.add(:base, "Sorry, that is a reserved word and cannot be used as a Username.")
    end
    if ObscenityChecker.maybe_profane?(username)
      return errors.add(:username, "cannot be profane.")
    end
    if username.blank?
      return errors.add(:username, "must be at least 4 characters.")
    end
    if username.include?(" ")
      errors.add(:username, "cannot contain spaces")
    end
    if username.include?("%")
      errors.add(:username, "cannot contain %'s")
    end
    if username.include?("@")
      errors.add(:username, "cannot contain @'s")
    end
    if username.include?("`")
      errors.add(:username, "cannot contain `'s")
    end
    unless username.length > 2
      errors.add(:username, "must be at least 3 characters")
    end
    unless username.length < 25
      errors.add(:username, "must be less than 25 characters")
    end
    unless username.gsub(/[^a-z]/i, "").length > 1
      errors.add(:username, "must have at least 2 normal alpha characters (A-Z)")
    end

    errors[:username].any?
  end

end
