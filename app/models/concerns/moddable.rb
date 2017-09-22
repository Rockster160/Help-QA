module Moddable
  extend ActiveSupport::Concern

  included do
    # Add role enum
    has_many :feedbacks
  end

  def admin?; false; end # FIXME by adding roles
  def mod?;   true; end # FIXME by adding roles

end
