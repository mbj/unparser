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
          write(O_DOT) if parentheses?
        end

        # Emit operator 
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_operator
          parens = parentheses? ? EMPTY_STRING : WS
          parentheses(parens, parens) { write(selector) }
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

        # Test for splat argument
        #
        # @return [true]
        #   if first argument is a splat
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def splat?
          right_node.type == :splat
        end

        # Test if parentheses are needed
        #
        # @return [true]
        #   if parenthes are needed
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def parentheses?
          splat? || children.length >= 4
        end
        memoize :parentheses?

        # Emit right
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_right
          node = right_node
          if parentheses?
            parentheses { delimited(children[2..-1]) }
            return
          end
          visit(node)
        end

      end # Binary
    end # Send
  end # Emitter
end # Unparser
