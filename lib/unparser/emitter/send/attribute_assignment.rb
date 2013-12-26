module Unparser
  class Emitter
    class Send
      # Emitter for send as attribute assignment
      class AttributeAssignment < self

        # Perform regular dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_selector
          visit_terminated(arguments.first)
        end

        # Emit receiver
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def emit_receiver
          visit_terminated(receiver)
          write(T_DOT)
        end

      end # AttributeAssignment
    end # Send
  end # Emitter
end # Unparser
