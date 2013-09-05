module Unparser
  class Emitter
    class Send
      # Emitter for "regular" receiver.selector(arguments...) case
      class Regular < self

      private

        # Perform regular dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_receiver
          emit_selector
          emit_arguments
        end

        # Return receiver
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def emit_receiver
          return unless first_child
          visit_terminated(receiver)
          write(T_DOT)
        end

      end # Regular
    end # Send
  end # Emitter
end # Unparser
