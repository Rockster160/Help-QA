module DeviseOverrides
  extend ActiveSupport::Concern

  included do
    attr_accessor :login
  end

  class_methods do
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.strip.downcase }]).first
    end

    def send_reset_password_instructions(attributes={})
      recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
      recoverable.send_reset_password_instructions if recoverable.persisted?
      recoverable
    end

    def find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
      (case_insensitive_keys || []).each {|k| attributes[k].try(:downcase!)}

      attributes = attributes.slice(*required_attributes)
      attributes.delete_if {|_key, value| value.blank?}

      if attributes.size == required_attributes.size
        if attributes.key?(:login)
          login = attributes.delete(:login)
          record = find_record(login)
        else
          record = where(attributes).first
        end
      end

      unless record
        record = new

        required_attributes.each do |key|
          value = attributes[key]
          record.send("#{key}=", value)
          record.errors.add(key, value.present? ? error : :blank)
        end
      end
      record
    end

    def find_record(login)
      where(["username = :value OR email = :value", {value: login}]).first
    end
  end


  def password_required?
    super if confirmed?
  end

  def confirm
    assign_attributes(verified_at: DateTime.current)
    save if confirmed?
    super
  end

  def confirm_with_password(params)
    errors.add(:password, "cannot be blank") if params[:password].blank?
    errors.add(:password_confirmation, "cannot be blank") if params[:password_confirmation].blank?
    errors.add(:password, "does not match confirmation.") unless params[:password] == params[:password_confirmation]

    return false if errors.any?

    update(params) && confirm
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

end
