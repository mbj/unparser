# frozen_string_literal: true

module Unparser
  class Emitter
    class Send
      # Emitter for send as attribute assignment
      class AttributeAssignment < self
        include Unterminated

        children :receiver, :selector, :first_argument

        # Perform regular dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_attribute
          write(T_ASN)

          if arguments.one?
            visit(first_argument)
          else
            parentheses { delimited(arguments) }
          end
        end

      private

        # Emit receiver
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def emit_receiver
          visit(receiver)
          write(T_DOT)
        end

        # Emit attribute
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_attribute
          write(non_assignment_selector)
        end
      end # AttributeAssignment
    end # Send
  end # Emitter
end # Unparser
