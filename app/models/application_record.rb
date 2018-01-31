class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def new_obj?
    if respond_to?(:created_at) && respond_to?(:updated_at)
      created_at == updated_at
    else
      new_record?
    end
  end
end
