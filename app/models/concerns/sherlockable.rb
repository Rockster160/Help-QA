module Sherlockable
  extend ActiveSupport::Concern
  attr_accessor :acting_user_id, :ignore_sherlock

  class_methods do
    def sherlockable(klass:, ignore: nil, skip: nil)
      ignore = [ignore].flatten
      skip = [skip].flatten
      self.send :after_save, proc {
        next if ignore_sherlock
        next if Rails.env.archive?
        discovery = Sherlock.discover(self, changes.reject { |change_key| change_key.blank? || change_key.to_sym.in?(ignore.to_a) }, klass)
        next unless discovery.present?
        discovery_type = discovery.set_discovery_type
        discovery.save unless discovery_type.in?(skip)
      }
    end
  end
end
