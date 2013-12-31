# encoding: utf-8

module Unparser
  class Emitter
    # Emitter for return nodes
    class Return < self

      handle :return

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RETURN)
        emit_break_return_arguments
      end

    end # Return
  end # Emitter
end # Unparser
