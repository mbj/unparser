module Unparser
  class Emitter
    # Base class for binary emitters
    class Binary < self

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
          write(WS, self.class::OPERATOR, WS)
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
        parentheses { visit(first_child) }
      end

      # Emit right
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_right
        parentheses { visit(children[1]) }
      end

      # Emitter for or nodes
      class Or < self
        OPERATOR = O_OR
        handle :or
      end # Or

      # Emitter for and nodes
      class And < self
        OPERATOR = O_AND
        handle :and
      end # And

    end # Binary
  end # Emitter
end # Unparser
