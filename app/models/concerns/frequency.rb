module Frequency
  extend ActiveSupport::Concern

  def sort_frequency(array)
    self.class.sort_frequency(array)
  end

  module ClassMethods
    def sort_frequency(array)
      # Returns the array uniquely sorted by the number of times each object appears in the array.
      array.each_with_object(Hash.new(0)) do |instance, count_hash|
        count_hash[instance] += 1
      end.sort_by { |instance, count| -count }.map(&:first)
    end
  end

end
