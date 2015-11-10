module Unparser
  class Emitter
    class Send
      # Emitter for binary sends
      class Binary < self
        include Unterminated

      private

        # Return undefined
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          visit_on_side(receiver, :left)
          emit_operator
          visit_on_side(right_node, :right)
        end

        # Emit operator
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_operator
          write(WS, string_selector, WS)
        end

        # Return right node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def right_node
          children[2]
        end

      end # Binary
    end # Send
  end # Emitter
end # Unparser
