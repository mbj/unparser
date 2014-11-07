# encoding: utf-8

module Unparser
  class Emitter
    class Send
      # Emitter for send as attribute assignment
      class AttributeAssignment < self
        include Unterminated

        # Perform regular dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_attribute
          emit_operator
          visit(arguments.first)
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
          write(attribute_name)
        end

        # Emit assignment operator
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_operator
          write(WS, T_ASN, WS)
        end

        # Return attribute name
        #
        # @return [String]
        #
        # @api private
        #
        def attribute_name
          string_selector[0..-2]
        end

      end # AttributeAssignment
    end # Send
  end # Emitter
end # Unparser
