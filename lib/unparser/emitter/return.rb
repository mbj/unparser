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
        write(K_RETURN)
        emit_arguments
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

    end # Return
  end # Emitter
end # Unparser
