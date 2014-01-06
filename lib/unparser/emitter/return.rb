# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for return nodes
    class Return < self

      handle :return

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        conditional_parentheses((parent_type == :or || parent_type == :and) && children.any?) do
          write(K_RETURN)
          emit_break_return_arguments
        end
      end

      # Emit break or return arguments
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_break_return_arguments
        return if children.empty?
        splat = children.any? { |child| child.type == :splat }
        if splat
          ws
        end
        head, *tail = children
        conditional_parentheses(!splat) { visit(head) }
        tail.each do |node|
          write(DEFAULT_DELIMITER)
          conditional_parentheses(!splat) { visit(node) }
        end
      end

    end # Return
  end # Emitter
end # Unparser
