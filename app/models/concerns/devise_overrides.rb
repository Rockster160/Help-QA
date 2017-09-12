module DeviseOverrides
  extend ActiveSupport::Concern

  def password_required?
    super if confirmed?
  end

  def confirm_with_password(params)
    errors.add(:password, "cannot be blank") if params[:password].blank?
    errors.add(:password_confirmation, "cannot be blank") if params[:password_confirmation].blank?
    errors.add(:password, "does not match confirmation.") unless params[:password] == params[:password_confirmation]

    return false if errors.any?

    update(params) && assign_attributes(verified_at: DateTime.current) && confirm
  end

end
