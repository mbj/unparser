# frozen_string_literal: true

module Unparser
  class Emitter
    # Emitter for array patterns
    class ArrayPattern < self

      handle :array_pattern

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write('[')
        children.each_with_index do |child, index|
          write(', ') unless index.zero?
          visit(child)
        end
        write(']')
      end
    end # Pin
  end # Emitter
end # Unparser
