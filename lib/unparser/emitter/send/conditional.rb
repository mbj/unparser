module Unparser
  class Emitter
    class Send
      # Emitter for "conditional" receiver&.selector(arguments...) case
      class Conditional < self
        include Terminated

        handle :csend

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

        # Emit receiver
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_receiver
          visit(receiver)
          write(T_AMP, T_DOT)
        end

      end # Regular
    end # Send
  end # Emitter
end # Unparser
