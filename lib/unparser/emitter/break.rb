# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for break nodes
    class Break < self

      handle :break

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        conditional_parentheses(parent_type == :or || parent_type == :and) do
          write(K_BREAK)
          emit_break_return_arguments
        end
      end

    end # Break
  end # Emitter
end # Unparser
