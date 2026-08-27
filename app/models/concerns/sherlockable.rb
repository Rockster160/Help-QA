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
        # `changes` is empty inside after_save from Rails 5.2 on -- the record is
        # no longer dirty by the time callbacks run. `saved_changes` carries the
        # same {attr => [before, after]} shape for the save that just happened.
        discovery = Sherlock.discover(self, saved_changes.reject { |change_key| change_key.blank? || change_key.to_sym.in?(ignore.to_a) }, klass)
        next unless discovery.present?
        discovery_type = discovery.set_discovery_type
        discovery.save unless discovery_type.in?(skip)
      }
    end
  end

  included do
    before_destroy :leave_no_sherlock_trace
  end

  def leave_no_sherlock_trace
    return if ignore_sherlock
    return if Rails.env.archive?

    Sherlock.create(
      obj:             self,
      changed_attrs:   {destroyed_at: nil},
      discovery_type: :delete,
      discovery_klass: self.class,
      new_attributes:  attributes.merge(destroyed_at: DateTime.current)
    )
  end
end
