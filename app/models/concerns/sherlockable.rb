module Sherlockable
  extend ActiveSupport::Concern

  class_methods do
    def sherlockable(klass:, ignore: [])
      self.send :after_save, proc {
        Sherlock.discover(self, changes.reject { |change_key| change_key.blank? || change_key.to_sym.in?(ignore.to_a) }, klass)
      }
    end
  end
end
