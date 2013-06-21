module Unparser
  class Emitter
    # Base class for binary emitters
    class Binary < self

      handle :or, :and
      children :left, :right

      MAP = {
        :or => T_OR,
        :and => T_AND
      }.freeze

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        parentheses do
          emit_left
          write(WS, MAP.fetch(node.type), WS)
          emit_right
        end
      end

      # Emit left
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_left
        parentheses { visit(left) }
      end

      # Emit right
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_right
        parentheses { visit(right) }
      end

    end # Binary
  end # Emitter
end # Unparser
