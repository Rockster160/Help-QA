module Defaults
  extend ActiveSupport::Concern

  # Added to instance of object
  included do
    after_initialize :apply_default_values
  end

  # Callback for setting default values
  def apply_default_values
    self.class.defaults_array.each do |attr_key, attr_val|
      next unless self.send(attr_key).nil?
      value = attr_val.respond_to?(:call) ? attr_val.call(self) : attr_val # Hack to pass in enum symbol instead of integer
      self.send("#{attr_key}=", value)
    end
    self.class.created_defaults_array.each do |attr_key, attr_val|
      next if self.persisted?
      next unless self.send(attr_key).nil?
      value = attr_val.respond_to?(:call) ? attr_val.call(self) : attr_val # Hack to pass in enum symbol instead of integer
      self.send("#{attr_key}=", value)
    end
  end

  # Added to class of object
  class_methods do
    def defaults(attribute_hash)
      attribute_hash.each do |attr_key, attr_val|
        created_defaults_array[attr_key] = attr_val
      end
    end

    def defaults_on_create(attribute_hash)
      attribute_hash.each do |attr_key, attr_val|
        created_defaults_array[attr_key] = attr_val
      end
    end

    def defaults_array
      @defaults_array ||= {}
    end
    def created_defaults_array
      @created_defaults_array ||= {}
    end
  end
end
