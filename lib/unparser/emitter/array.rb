# frozen_string_literal: true

module Unparser
  class Emitter
    # Array literal emitter
    class Array < self
      handle :array

    private

      def dispatch
        parentheses('[', ']') do
          delimited(emitters, &:write_to_buffer)
        end
      end

      def emitters
        children.map(&method(:emitter))
      end
      memoize :emitters
    end # Array
  end # Emitter
end # Unparser
