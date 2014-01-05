# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for next nodes
    class Next < self

      handle :next

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        conditional_parentheses(parent_type == :or || parent_type == :and) do
          write(K_NEXT)
          unless children.empty?
            visit_parentheses(children.first)
          end
        end
      end

    end # Next
  end # Emitter
end # Unparser
