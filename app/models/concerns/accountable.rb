module Accountable
  extend ActiveSupport::Concern
  RESERVED_WORDS_FOR_USERNAME = ["anonymous", "guest"].freeze

  included do
    before_validation :set_default_username, :set_slug

    validates_uniqueness_of :username, :slug, message: "Sorry, that Username has already been taken."
    validate :username_meets_requirements
    validate :at_least_13_years_of_age

    after_create :set_gravatar_if_exists, :create_associated_objects, :send_confirmation_email
    after_commit :reset_cache
    after_update :reset_auth_token, if: :encrypted_password_changed?
  end

  def online?
    return false unless last_seen_at
    last_seen_at > 5.minutes.ago
  end
  def offline?; !online?; end
  def verified?; verified_at?; end
  def long_term_user?; created_at < 1.year.ago; end
  def long_time_user?; long_term_user?; end
  def deactivated?; !verified? && created_at < 1.day.ago; end
  def banned?; banned_until? && banned_until > DateTime.current; end
  def perma_banned?; banned_until? && banned_until > 50.years.from_now; end

  def see!
    update(last_seen_at: DateTime.current)
  end

  def account_completion
    steps = {
      "Confirm account (Verify email and add password)" => verified? && encrypted_password.present?,
      "Update Username" => has_updated_username?,
      "Upload Avatar" => avatar_url.present?,
      "Add Bio" => profile.about.present?,
      "Make your first post" => posts.count.positive?,
      "Help somebody (Comment on a post)" => replies.joins(:post).where.not(posts: { author_id: id }).count.positive?
    }
    update(completed_signup: true) if !completed_signup? && steps.values.all?
    steps
  end

  def send_confirmation_instructions
    # Stubbing this method so Devise doesn't send it's own emails
  end

  def send_confirmation_email
    new_user = created_at == updated_at
    recently_emailed = confirmation_sent_at.present? && confirmation_sent_at < 10.seconds.ago
    return unless new_user || recently_emailed
    delay.deliver_confirmation_email
  end

  def deliver_confirmation_email
    update(confirmation_sent_at: DateTime.current)
    UserMailer.confirmation_instructions(self).deliver_now
  end

  def ip_address
    location.try(:ip) || current_sign_in_ip || last_sign_in_ip || username || email || id
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
    Sherlock.user_changes(self).each do |sherlock|
      next unless sherlock.changes.keys.include?("username")
      previous_usernames << sherlock.changes["username"].first
    end
    previous_usernames.shift
    previous_usernames.uniq
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
    ActionController::Base.new.expire_fragment("invite_loader") if previous_changes.keys.include?("username")
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
    username.try(:squish!)
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

  def username_meets_requirements
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
    if username.include?("@")
      errors.add(:username, "cannot contain @'s'")
    end
    unless username.length > 3
      errors.add(:username, "must be at least 4 characters")
    end
    unless username.length < 25
      errors.add(:username, "must be less than 25 characters")
    end
    unless username.gsub(/[^a-z]/i, "").length > 1
      errors.add(:username, "must have at least 2 normal alpha characters (A-Z)")
    end
  end

end
