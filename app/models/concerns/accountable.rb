module Accountable
  extend ActiveSupport::Concern

  included do
    before_validation :set_default_username
    validates_presence_of :date_of_birth
    validates_uniqueness_of :username
    validate :username_meets_requirements
  end

  def online?
    return false unless last_seen_at
    last_seen_at > 5.minutes.ago
  end
  def offline?; !online?; end
  def verified?; verified_at?; end
  def long_term_user?; created_at < 1.year.ago; end

  def see!
    update(last_seen_at: DateTime.current)
  end

  def account_completion
    {
      "Confirm account (Verify email and add password)" => verified? && encrypted_password.present?,
      "Update Username" => false,
      "Upload Avatar" => avatar_url.present?,
      "Update Bio" => false,
      "Make your first post" => posts.count.positive?,
      "Help somebody (Comment on a post)" => replies.joins(:post).where.not(posts: { author_id: id }).count.positive?
    }
  end

  def activity(day_count)
    activity_hash = {}
    day_count.times do |t|
      date = (t + 1).days.ago
      posts_on_date = posts.where(created_at: date.beginning_of_day..date.end_of_day)
      replies_on_date = replies.where(created_at: date.beginning_of_day..date.end_of_day)
      activity_hash[date.to_date.to_s] = {posts: posts_on_date.length, replies: replies_on_date.length}
    end
    activity_hash
  end

  def ip_address
    location.try(:ip) || current_sign_in_ip || last_sign_in_ip || username || email || id
  end

  def age
    return unless date_of_birth.present?
    now = Time.now.utc.to_date
    dob = date_of_birth
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
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
      nil
    end
  end

  def letter
    return "?" unless username.present?
    (username.gsub(/[^a-z]/i, '').first.presence || "?").upcase
  end

  def avatar
    avatar_url.presence || letter.presence || 'status_offline.png'
  end

  def to_param
    [id, username.parameterize].join("-")
  end

  private

  def set_default_username
    t = 0
    base_username = email.split("@").first
    loop do
      break if base_username.length >= 4
      base_username = "#{base_username}#{base_username}"
    end
    self.username ||= loop do
      try_username = t == 0 ? base_username : "#{base_username}#{t + 1}"
      t += 1
      break try_username if User.where(username: try_username).none?
    end
    username.try(:squish!)
  end

  def username_meets_requirements
    return unless email.present?
    # Profanity filter?

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
