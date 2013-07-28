module Unparser
  class Emitter
    class Send
      # Emitter for binary sends
      class Binary < self

      private

        # Return undefined
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_operator
          emit_right
        end

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          emit_unambiguous_receiver
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
