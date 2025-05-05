# frozen_string_literal: true

module Unparser
  # Original code before vendoring and reduction from: https://github.com/mbj/mutant/blob/main/lib/mutant/util.rb
  module Util
    # Error raised by `Util.one` if size is not exactly one
    SizeError = Class.new(IndexError)

    # Return only element in array if it contains exactly one member
    #
    # @param array [Array]
    #
    # @return [Object] first entry
    def self.one(array)
      case array
      in [value]
        value
      else
        fail SizeError, "expected size to be exactly 1 but size was #{array.size}"
      end
    end
  end
end
