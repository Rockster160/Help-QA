module Moddable
  extend ActiveSupport::Concern

  included do
    has_one :mod_abilities, dependent: :destroy
    has_many :feedbacks, dependent: :destroy

    enum role: {
      default:      0,
      trusted_user: 1,
      ancient_user: 2,
      mod:          3,
      admin:        4,
      dev:          5
    }

    self.defined_enums["role"].each do |initial_enum_str_val, initial_enum_int_val|
      define_singleton_method initial_enum_str_val do
        where("users.role >= ?", initial_enum_int_val || 0)
      end
      define_singleton_method "only_#{initial_enum_str_val}" do
        where("users.role = ?", initial_enum_int_val || 0)
      end
      define_method("#{initial_enum_str_val}?") do
        user_role_val = self.class.roles[self.role] || 0

        user_role_val >= initial_enum_int_val
      end
    end
  end

  def become!(new_role); update(role: self.class.roles[new_role]); end

  def abilities
    mod_abilities || create_mod_abilities
  end

  def can?(ability)
    return false unless mod?
    abilities&.send(ability)
  end
end
