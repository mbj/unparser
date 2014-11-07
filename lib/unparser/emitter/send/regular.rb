# encoding: utf-8

module Unparser
  class Emitter
    class Send
      # Emitter for "regular" receiver.selector(arguments...) case
      class Regular < self
        include Terminated

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
          return unless first_child
          visit(receiver)
          write(T_DOT)
        end

      end # Regular
    end # Send
  end # Emitter
end # Unparser
