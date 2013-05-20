module Unparser
  class Emitter
    # Emitter if nodes
    class If < self

      handle :if

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(keyword, WS)
        emit_condition
        emit_if_branch
        emit_else_branch
        k_end
      end

      # Test for unless
      #
      # @return [true]
      #   if to emit as unless
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def unless?
        !children[1]
      end

      # Return keyword
      #
      # @return [String]
      #
      # @api private
      #
      def keyword
        unless? ? K_UNLESS : K_IF
      end

      # Emit condition
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition
        visit(first_child)
      end

      # Emit if branch
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_if_branch
        node = children[1]
        return unless node
        indented { visit(node) }
      end

      # Emit else branch
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else_branch
        else_branch = children[2]
        return unless else_branch
        write(K_ELSE) unless unless?
        indented { visit(else_branch) }
      end

    end # If
  end # Emitter
end # Unparser
