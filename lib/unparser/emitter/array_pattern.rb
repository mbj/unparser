# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for array patterns
    class ArrayPattern < self

      handle :array_pattern
      handle :array_pattern_with_tail

    private

      def dispatch
        write('[')
        delimited(children)
        write(', ') if node_type.equal?(:array_pattern_with_tail)
        write(']')
      end
    end # Pin
  end # Emitter
end # Unparser
