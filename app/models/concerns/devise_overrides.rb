module DeviseOverrides
  extend ActiveSupport::Concern

  def password_required?
    super if confirmed?
  end

end
