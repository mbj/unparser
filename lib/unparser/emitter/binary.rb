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
          parentheses { visit(first_child) }
          write(WS, self.class::OPERATOR, WS)
          parentheses { visit(children[1]) }
        end
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
