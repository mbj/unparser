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
          emit_arguments
        end
      end

      # Emit arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_arguments
        return if children.empty?
        head, *tail = children
        parentheses { visit(head) }
        tail.each do |node|
          write(DEFAULT_DELIMITER)
          parentheses { visit(node) }
        end
      end

    end # Break
  end # Emitter
end # Unparser
