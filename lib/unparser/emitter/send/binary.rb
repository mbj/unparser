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
          visit(receiver)
          emit_operator
          emit_right
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

        # Emit right
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_right
          visit(right_node)
        end

      end # Binary
    end # Send
  end # Emitter
end # Unparser
